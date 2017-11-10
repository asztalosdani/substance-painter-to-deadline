// Copyright (C) 2017 Allegorithmic
//
// This software may be modified and distributed under the terms
// of the MIT license.  See the LICENSE file for details.

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
            if (documentStructure != null) {
                var materials = documentStructure.materials
                for (var i = 0; i < materials.length; i++) {
                    var material = materials[i]
                    alg.log.info(material.name)
                    dataModel.append({name:material.name, selected: true})
                }
            }
        }

        function submit() {
            for (var i = 0; i < dataModel.count; i++) {
                var textureSet = dataModel.get(i)
                alg.log.info(textureSet.name + " " + textureSet.selected)
            }

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
                InitialStatus: "Suspended", // submitSuspended.checked ? "Suspended" : "Active"
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
                Format: format.currentText
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
//        anchors.fill: parent
        anchors.margins: 12
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        ColumnLayout {
            anchors.fill: parent
//            Rectangle {
//                color: "red"
//                anchors.fill: parent
//            }

            Separator {
                text: "Job Description"
            }

            GridLayout {
                columns: 2
//                Layout.fillWidth: true
//                anchors {
////                    top: parent.top
//                    left: parent.left
//                    right: parent.right
//                }

                AlgLabel { text: "Job Name"}
                AlgTextEdit { id: jobName; Layout.fillWidth: true}

                AlgLabel { text: "Comment"}
                AlgTextEdit { id: comment; Layout.fillWidth: true}

                AlgLabel { text: "Department"}
                AlgTextEdit { id: department; Layout.fillWidth: true}
            }

            Separator {
                text: "Job Options"
            }

            GridLayout {
                columns: 3

                AlgLabel { text: "Pool"; Layout.row: 0; Layout.column: 0}
                AlgComboBox {
                    id: pool
                    Layout.row: 0; Layout.column: 1
                    model: ListModel {id: poolModel}
                }


                AlgLabel { text: "Secondary Pool"; Layout.row: 1; Layout.column: 0}
                AlgComboBox {
                    id: secondaryPool
                    Layout.row: 1; Layout.column: 1
                    model: ListModel {id: secondaryPoolModel}
                }

                AlgLabel { text: "Group"; Layout.row: 2; Layout.column: 0}
                AlgComboBox {
                    id: group
                    Layout.row: 2; Layout.column: 1
                    model: ListModel {id: groupModel}
                }

                AlgLabel { text: "Priority"; Layout.row: 3; Layout.column: 0}
                AlgSpinBox {
                    id: priority
                    Layout.row: 3; Layout.column: 1
                    minValue: 0
                    maxValue: 100
                    precision: 0
                    value: 50
                }

                AlgLabel { text: "Task Timeout"; Layout.row: 4; Layout.column: 0}
                AlgSpinBox {
                    id: taskTimeout
                    Layout.row: 4; Layout.column: 1
                    minValue: 0
                    maxValue: 1000000
                    precision: 0
                    value: 0
                }
                AlgCheckBox {
                    id: enableAutoTaskTimeout
                    text: "Enable Auto Task Timeout"
                }

                AlgLabel { text: "Concurrent Tasks"}
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

                AlgLabel { text: "Machine Limit"}
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

                AlgLabel { text: "Machine List"}
                RowLayout {
                    Layout.columnSpan: 2
                    Layout.fillWidth: true

                    AlgTextEdit { id: machineList; Layout.fillWidth: true; Layout.fillHeight: true}
                    AlgButton {
                        id: machineListButton
                        text: "..."
                        Layout.maximumWidth: 30
                    }
                }

                AlgLabel { text: "Limits"}
                RowLayout {
                    Layout.columnSpan: 2
                    Layout.fillWidth: true

                    AlgTextEdit { id: limits; Layout.fillWidth: true; Layout.fillHeight: true}
                    AlgButton {
                        id: limitsButton
                        text: "..."
                        Layout.maximumWidth: 30
                    }
                }

                AlgLabel { text: "Dependencies"}
                RowLayout {
                    Layout.columnSpan: 2
                    Layout.fillWidth: true

                    AlgTextEdit { id: dependencies; Layout.fillWidth: true; Layout.fillHeight: true}
                    AlgButton {
                        id: dependenciesButton
                        text: "..."
                        Layout.maximumWidth: 30
                    }
                }

                AlgLabel { text: "On Job Complete"}
                AlgComboBox {
                    id: onJobComplete
                    model: ["Nothing", "Archive", "Delete"]
                }
                AlgCheckBox {
                    id: submitSuspended
                    text: "Submit Job As Suspended"
                }
            }

            Separator {
                text: "Export options"
            }

            GridLayout {
                columns: 3

                AlgLabel { text: "Export Path"}
                RowLayout {
                    Layout.columnSpan: 2
                    Layout.fillWidth: true

                    AlgTextEdit { id: exportPath; Layout.fillWidth: true; Layout.fillHeight: true; text:"c:/temp/substance_export"}
                    AlgButton {
                        id: browseExportButton
                        text: "Browse"
                        Layout.maximumWidth: 50
                    }
                }

                AlgLabel { text: "Preset Path"}
                RowLayout {
                    Layout.columnSpan: 2
                    Layout.fillWidth: true

                    AlgTextEdit { id: presetPath; Layout.fillWidth: true; Layout.fillHeight: true; text:"x:/main/Personal/DavidF/Substance/Puppet UDIM version.spexp"}
                    AlgButton {
                        id: browsePresetButton
                        text: "Browse"
                        Layout.maximumWidth: 50
                    }
                }

                AlgLabel { text: "Format"}
                AlgComboBox {
                    id: format
                    model: ["bmp", "ico", "jpeg", "jng", "pbm", "pgm", "ppm", "png", "targa", "tiff", "wbmp", "xpm", "gif", "hdr", "exr", "j2k", "jpeg-2000", "pfm", "psd"]
                }
                AlgComboBox {
                    id: bitDepth
                    model: ["8bit", "16bit", "32bit"]
                }
            }


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

}

