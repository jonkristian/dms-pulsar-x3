import QtQuick
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginSettings {
    id: root
    pluginId: "pulsarX3"

    StyledText {
        width: parent.width
        text: "Pulsar X3 Mouse"
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Font.Bold
        color: Theme.surfaceText
    }

    StyledText {
        width: parent.width
        text: "Monitor battery and DPI of your Pulsar X3 gaming mouse. Uses the pulsar-x3 CLI tool to communicate with the device."
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.surfaceVariantText
        wrapMode: Text.WordWrap
    }
}
