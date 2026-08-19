import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as P5Support

PlasmoidItem {
    id: root
    preferredRepresentation: compactRepresentation

    property var presetNames: []
    property string activePreset: ""
    property var dynamicActions: []

    Plasmoid.icon: "com.github.wwmm.easyeffects"

    function shellQuote(s) {
        return "'" + String(s).replace(/'/g, "'\\''") + "'"
    }

    // fire-and-forget commands (launch app, load preset)
    P5Support.DataSource {
        id: runner
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => disconnectSource(sourceName)
        function run(cmd) {
            connectSource(cmd)
        }
    }

    // reads the list of saved presets
    P5Support.DataSource {
        id: presetSource
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => {
            const out = (data["stdout"] || "")
            const names = []
            const lines = out.split("\n")
            for (let i = 0; i < lines.length; i++) {
                const line = lines[i]
                const idx = line.indexOf(":")
                if (idx === -1) continue
                const label = line.slice(0, idx).trim()
                if (label === "Output Presets" || label === "Input Presets") {
                    const rest = line.slice(idx + 1).trim()
                    if (rest.length > 0) {
                        const parts = rest.split(",")
                        for (let j = 0; j < parts.length; j++) {
                            const name = parts[j].trim()
                            if (name.length > 0) {
                                names.push(name)
                            }
                        }
                    }
                }
            }
            root.presetNames = names
            disconnectSource(sourceName)
        }
    }

    // reads which preset is currently active on the output
    P5Support.DataSource {
        id: activeSource
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => {
            const out = (data["stdout"] || "").trim()
            const idx = out.indexOf(":")
            root.activePreset = idx === -1 ? out : out.slice(idx + 1).trim()
            disconnectSource(sourceName)
        }
    }

    function refreshPresets() {
        presetSource.connectSource("easyeffects -p 2>/dev/null")
        activeSource.connectSource("easyeffects -s output 2>/dev/null")
    }

    function loadPreset(name) {
        runner.run("easyeffects -l " + shellQuote(name))
        refreshTimer.restart()
    }

    function launchApp() {
        runner.run("easyeffects")
    }

    Component.onCompleted: refreshPresets()

    Timer {
        id: refreshTimer
        interval: 800
        repeat: false
        onTriggered: root.refreshPresets()
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: root.refreshPresets()
    }

    PlasmaCore.Action {
        id: headerAction
        text: "Profilok"
        enabled: false
    }


    PlasmaCore.Action {
        id: refreshAction
        text: "Profilok frissítése"
        icon.name: "view-refresh"
        onTriggered: root.refreshPresets()
    }

    Component {
        id: presetActionComponent
        PlasmaCore.Action {
            checkable: true
        }
    }

    function buildContextualActions() {
        for (let i = 0; i < root.dynamicActions.length; i++) {
            root.dynamicActions[i].destroy()
        }
        const acts = [headerAction]
        const created = []
        for (let i = 0; i < root.presetNames.length; i++) {
            const name = root.presetNames[i]
            const action = presetActionComponent.createObject(root, {
                text: name,
                checked: (name === root.activePreset)
            })
            action.triggered.connect(function () { root.loadPreset(name) })
            acts.push(action)
            created.push(action)
        }
        root.dynamicActions = created
        acts.push(refreshAction)
        return acts
    }

    Plasmoid.contextualActions: buildContextualActions()

    compactRepresentation: MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        hoverEnabled: true

        onClicked: root.launchApp()

        Kirigami.Icon {
            anchors.fill: parent
            source: "com.github.wwmm.easyeffects"
        }

        QQC2.ToolTip.visible: containsMouse
        QQC2.ToolTip.text: "EasyEffects"
    }

    fullRepresentation: Item {
        Layout.minimumWidth: Kirigami.Units.iconSizes.medium
        Layout.minimumHeight: Kirigami.Units.iconSizes.medium

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            onClicked: root.launchApp()

            Kirigami.Icon {
                anchors.fill: parent
                anchors.margins: 4
                source: "com.github.wwmm.easyeffects"

            }
        }
    }
}