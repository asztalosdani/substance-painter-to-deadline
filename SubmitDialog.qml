import QtQuick 2.5
import QtQml 2.2
import QtQml.Models 2.2
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.4
import AlgWidgets 1.0
import AlgWidgets.Style 1.0
import "deadline.js" as Deadline

AlgDialog
{
    id: root
    visible: false
    title: "Submit to deadline"
    width: 480
    height: 600
    minimumWidth: 480
    minimumHeight: 600
//    maximumWidth: width
//    maximumHeight: height
    defaultButtonText: "Submit"

    Component.onCompleted: {
        internal.initModels()
//        internal.emit()
    }

    onAccepted: {
        internal.submit()
    }

    onVisibleChanged: {
      if (visible) internal.initModels()
    }

    QtObject {
        id: internal

        function initModels() {
            Deadline.getPools(fillPoolCombobox)
            Deadline.getGroups(fillGroupCombobox)

            initDataModel()
        }

        function fillPoolCombobox(pools) {
            poolModel.clear()
            secondaryPoolModel.clear()
            pools.sort()
            for (var i = 0; i<pools.length; i++) {
                var pool = pools[i]
                poolModel.append({text:pool})
                secondaryPoolModel.append({text:pool})
            }
        }

        function fillGroupCombobox(groups) {
            groupModel.clear()
            groups.sort()
            for (var i = 0; i<groups.length; i++) {
                var group = groups[i]
                groupModel.append({text:group})
            }
        }

        function initDataModel(){
            dataModel.clear()
            var documentStructure = alg.mapexport.documentStructure()
            if (documentStructure != null && documentStructure.materials) {
                var materials = documentStructure.materials
                for (var i = 0; i < materials.length; i++) {
                    var material = materials[i]
                    alg.log.info(material.name)
                    dataModel.append({name:material.name, selected: true})
                }
            }
        }

        function submit() {
            var textureSets = []
            for (var i = 0; i < dataModel.count; i++) {
                var textureSet = dataModel.get(i)
                alg.log.info(textureSet.name + " " + textureSet.selected)
                if (textureSet.selected) {
                    textureSets.push(textureSet.name)
                }
            }
            var bitDepth = bitDepthComboBox.currentText.split("bit")[0]

            var jobInfo = {
                Plugin: "SubstancePainter",
                Frames: 1,
                Name: jobName.text,
                Comment: comment.text,
                Department: department.text,
                Pool: pool.currentText,
                SecondaryPool: secondaryPool.currentText,
                Group: group.currentText,
                Priority: priority.value,
                ConcurrentTasks: concurrentTasks.value,
                LimitConcurrentTasksToNumberOfCpus: limitTasksToSlavesTaskLimit.checked,
                OnJobComplete: onJobComplete.currentText,
                InitialStatus: submitSuspended.checked ? "Suspended" : "Active",
                TaskTimeoutMinutes: taskTimeout.value,
                EnableAutoTimeout: enableAutoTaskTimeout.checked,
                MachineLimit: machineLimit.value,
                WhiteList: isBlackList.checked ? "" : machineList.text,
                BlackList: isBlackList.checked ? machineList.text : "",
                LimitGroups: limits.text,
                JobDependencies: dependencies.text,

                UserName: alg.settings.value("User")

                // OutputDirectory TODO
            }

            var pluginInfo = {
                ProjectFile: alg.project.url(),
                Preset: presetPath.text,
                ExportPath: exportPath.text,
                Format: format.currentText,
                TextureSets: textureSets.join(","),
                BitDepth: bitDepth
            }
            Deadline.submitJob(jobInfo, pluginInfo, onJobSubmitted)
        }

        function onJobSubmitted(response) {
            alg.log.info(response)
        }

    }

    Rectangle {
        id: content
        color: "transparent"
        parent: contentItem
        anchors.fill: parent
        anchors.margins: 12
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        ColumnLayout {
            anchors.fill: parent

            Separator {
                text: "Job Description"
            }

            GridLayout {
                columns: 2

                AlgLabel { text: "Job Name"}
                AlgTextInput { id: jobName; Layout.fillWidth: true}

                AlgLabel { text: "Comment"}
                AlgTextInput { id: comment; Layout.fillWidth: true}

                AlgLabel { text: "Department"}
                AlgTextInput { id: department; Layout.fillWidth: true}
            }

            Separator {
                text: "Job Options"
            }

            GridLayout {
                columns: 2

                AlgLabel { text: "Pool"}
                AlgComboBox {
                    id: pool
                    model: ListModel {id: poolModel}
                }

                AlgLabel { text: "Secondary Pool"}
                AlgComboBox {
                    id: secondaryPool
                    model: ListModel {id: secondaryPoolModel}
                }

                AlgLabel { text: "Group"}
                AlgComboBox {
                    id: group
                    model: ListModel {id: groupModel}
                }

                AlgLabel { text: "Priority"}
                AlgSpinBox {
                    id: priority
                    minValue: 0
                    maxValue: 100
                    precision: 0
                    value: 50
                }

                AlgLabel { text: "Task Timeout"}
                RowLayout {
                    Layout.fillWidth: true
                    AlgSpinBox {
                        id: taskTimeout
                        minValue: 0
                        maxValue: 1000000
                        precision: 0
                        value: 0
                    }
                    AlgCheckBox {
                        id: enableAutoTaskTimeout
                        text: "Enable Auto Task Timeout"
                    }
                }

                AlgLabel { text: "Concurrent Tasks"}
                RowLayout {
                    Layout.fillWidth: true
                    AlgSpinBox {
                        id: concurrentTasks
                        minValue: 1
                        maxValue: 16
                        precision: 0
                        value: 1
                    }
                    AlgCheckBox {
                        id: limitTasksToSlavesTaskLimit
                        text: "Limit Tasks To Slave's Task Limit"
                        checked: true
                    }
                }

                AlgLabel { text: "Machine Limit"}
                RowLayout {
                    Layout.fillWidth: true
                    AlgSpinBox {
                        id: machineLimit
                        minValue: 0
                        maxValue: 1000000
                        precision: 0
                        value: 0
                    }
                    AlgCheckBox {
                        id: isBlackList
                        text: "Machine List Is A Blacklist"
                    }
                }

                AlgLabel { text: "Machine List"}
                RowLayout {
                    Layout.fillWidth: true

                    AlgTextInput { id: machineList; Layout.fillWidth: true}
                    AlgButton {
                        id: machineListButton
                        text: "..."
                        Layout.maximumWidth: 30
                    }
                }

                AlgLabel { text: "Limits"}
                RowLayout {
                    Layout.fillWidth: true

                    AlgTextInput { id: limits; Layout.fillWidth: true}
                    AlgButton {
                        id: limitsButton
                        text: "..."
                        Layout.maximumWidth: 30
                    }
                }

                AlgLabel { text: "Dependencies"}
                RowLayout {
                    Layout.fillWidth: true

                    AlgTextInput { id: dependencies; Layout.fillWidth: true}
                    AlgButton {
                        id: dependenciesButton
                        text: "..."
                        Layout.maximumWidth: 30
                    }
                }

                AlgLabel { text: "On Job Complete"}
                RowLayout {
                    Layout.fillWidth: true
                    AlgComboBox {
                        id: onJobComplete
                        model: ["Nothing", "Archive", "Delete"]
                    }
                    AlgCheckBox {
                        id: submitSuspended
                        text: "Submit Job As Suspended"
                    }
                }
            }

            Separator {
                text: "Export options"
            }

            GridLayout {
                columns: 2

                AlgLabel { id: exportLabel; text: "Export Path"}
                RowLayout {
                    Layout.fillWidth: true

                    AlgTextInput {
                        id: exportPath
                        Layout.fillWidth: true
                        text:"c:/temp/substance_export"
                    }
                    AlgButton {
                        id: browseExportButton
                        text: "Browse"
                        Layout.maximumWidth: 50
                        onClicked: {
                            exportPathDialog.folder = alg.fileIO.localFileToUrl(exportPath.text)
                            exportPathDialog.open()
                        }
                    }
                }

                AlgLabel { text: "Preset Path"}
                RowLayout {
                    Layout.fillWidth: true

                    AlgTextInput { id: presetPath; Layout.fillWidth: true; text:"x:/main/Personal/DavidF/Substance/Puppet UDIM version.spexp"}
                    AlgButton {
                        id: browsePresetButton
                        text: "Browse"
                        Layout.maximumWidth: 50
                        onClicked: {
                            var path = presetPath.text.substr(0, presetPath.text.lastIndexOf("/"))
                            presetFileDialog.folder = alg.fileIO.localFileToUrl(path)
                            presetFileDialog.open()
                        }
                    }
                }

                AlgLabel { text: "Format"}
                AlgComboBox {
                    id: format
                    model: ["bmp", "ico", "jpeg", "jng", "pbm", "pgm", "ppm", "png", "targa", "tiff", "wbmp", "xpm", "gif", "hdr", "exr", "j2k", "jpeg-2000", "pfm", "psd"]
                }

                AlgLabel { text: "Bit Depth"}
                AlgComboBox {
                    id: bitDepthComboBox
                    model: ["8bit", "16bit", "32bit"]
                }
            }


            AlgLabel { text: "Texture Sets"}
            ListView {
                width: 180; height: 200
                model: ListModel {id: dataModel}
                delegate: dataDelegate
            }
        }
    }


    Component {
        id: dataDelegate
        Row {
            spacing: 10
            AlgCheckBox {
                text: name
                checked: selected
                onClicked: {dataModel.setProperty(index, "selected", checked)}
            }
        }
    }

    FileDialog {
        id: presetFileDialog
        title: "Select the export preset"
        nameFilters: ["Substance Painter Export Preset(*.spexp)"]
        onAccepted: {
            presetPath.text = alg.fileIO.urlToLocalFile(fileUrl.toString())
        }
    }

    FileDialog {
        id: exportPathDialog
        title: "Select the export folder"
        selectFolder: true
        onAccepted: {
            exportPath.text = alg.fileIO.urlToLocalFile(fileUrl.toString())
        }
    }

}

