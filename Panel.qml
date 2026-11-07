import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Ui
import "Model.js" as Model

// Minimal popup panel for converting dates between Solar Hijri (Jalali)
// and Gregorian calendars.
Panel {
  id: root
  moduleName: "hosi.jalali-gregorian-converter"
  ipcTarget: "hosi.jalali-gregorian-converter"
  manageIpc: false

  property var anchorItem: null
  property var hostWidget: null
  readonly property var barIdentity: hostWidget || root

  property bool fromPersian: true
  property string resultText: ""
  property bool hasError: false
  property bool copied: false

  readonly property color contentForeground: bar ? bar.foreground : Color.foreground
  readonly property string contentFontFamily: bar ? bar.fontFamily : Style.font.family

  function setCenterHoverRevealSuppressed(value) {
    if (root.bar && typeof root.bar.setCenterHoverRevealSuppressed === "function")
      root.bar.setCenterHoverRevealSuppressed(value)
    else if (root.bar && "centerHoverRevealSuppressed" in root.bar)
      root.bar.centerHoverRevealSuppressed = value
  }

  function open() {
    root.hasError = false
    root.copied = false
    root.resultText = ""
    root.controller.show()
    Qt.callLater(function() {
      if (root.opened) {
        root.setCenterHoverRevealSuppressed(true)
        yearField.selectAll()
        yearField.forceActiveFocus()
      }
    })
  }

  function close() {
    root.setCenterHoverRevealSuppressed(false)
    root.controller.hide()
  }

  function toggle() { if (root.opened) root.close(); else root.open() }

  function switchPanel(direction) {
    if (root.bar && typeof root.bar.switchPanelFrom === "function")
      return root.bar.switchPanelFrom(root.barIdentity, direction)
    return false
  }

  function swapDirection() {
    root.fromPersian = !root.fromPersian
    root.hasError = false
    root.copied = false
    root.resultText = ""
    yearField.selectAll()
    yearField.forceActiveFocus()
  }

  function clearFeedback() {
    root.hasError = false
    root.copied = false
  }

  function doConvert() {
    var out = Model.convert(yearField.text, monthField.text, dayField.text, root.fromPersian)
    root.hasError = !out.ok
    root.copied = false
    root.resultText = out.ok ? out.text : "Enter a valid date"
  }

  function copyResult() {
    if (root.hasError || root.resultText === "" || root.resultText === "Enter a valid date") return
    Quickshell.execDetached(["bash", "-c", "printf %s " + Util.shellQuote(root.resultText) + " | wl-copy"])
    root.copied = true
  }

  KeyboardPanel {
    id: panel
    anchorItem: root.anchorItem
    owner: root.barIdentity
    bar: root.bar
    open: root.opened
    centerOnBar: false
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(360))
    contentHeight: panel.fittedContentHeight(contentColumn.implicitHeight)

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onActivateRequested: root.doConvert()
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }
      onTextKey: function(t) {
        if (t === "s" || t === "S") root.swapDirection()
      }

      Column {
        id: contentColumn
        anchors.fill: parent
        spacing: Style.space(12)

        RowLayout {
          width: parent.width
          spacing: Style.space(8)

          Text {
            Layout.fillWidth: true
            text: Model.directionLabel(root.fromPersian)
            textFormat: Text.PlainText
            color: root.contentForeground
            font.family: root.contentFontFamily
            font.pixelSize: Style.font.subtitle
            font.bold: true
            elide: Text.ElideRight
          }

          PanelActionButton {
            size: Style.space(30)
            fontSize: Style.font.iconMedium
            iconText: "󰒟"
            tooltipText: "Swap direction (S)"
            foreground: root.contentForeground
            fontFamily: root.contentFontFamily
            onClicked: root.swapDirection()
          }
        }

        Row {
          width: parent.width
          spacing: Style.space(8)

          Column {
            width: (parent.width - parent.spacing * 2) * 0.4
            spacing: Style.space(4)
            Text { width: parent.width; text: "Year"; textFormat: Text.PlainText; color: Qt.darker(root.contentForeground, 1.4); font.family: root.contentFontFamily; font.pixelSize: Style.font.bodySmall; horizontalAlignment: Text.AlignHCenter }
            TextField {
              id: yearField
              width: parent.width
              horizontalAlignment: TextInput.AlignHCenter
              inputMethodHints: Qt.ImhDigitsOnly
              maximumLength: 4
              foreground: root.contentForeground
              font.family: root.contentFontFamily
              onTextChanged: root.clearFeedback()
              Keys.onReturnPressed: root.doConvert()
              Keys.onEnterPressed: root.doConvert()
            }
          }
          Column {
            width: (parent.width - parent.spacing * 2) * 0.3
            spacing: Style.space(4)
            Text { width: parent.width; text: "Month"; textFormat: Text.PlainText; color: Qt.darker(root.contentForeground, 1.4); font.family: root.contentFontFamily; font.pixelSize: Style.font.bodySmall; horizontalAlignment: Text.AlignHCenter }
            TextField {
              id: monthField
              width: parent.width
              horizontalAlignment: TextInput.AlignHCenter
              inputMethodHints: Qt.ImhDigitsOnly
              maximumLength: 2
              foreground: root.contentForeground
              font.family: root.contentFontFamily
              onTextChanged: root.clearFeedback()
              Keys.onReturnPressed: root.doConvert()
              Keys.onEnterPressed: root.doConvert()
            }
          }
          Column {
            width: (parent.width - parent.spacing * 2) * 0.3
            spacing: Style.space(4)
            Text { width: parent.width; text: "Day"; textFormat: Text.PlainText; color: Qt.darker(root.contentForeground, 1.4); font.family: root.contentFontFamily; font.pixelSize: Style.font.bodySmall; horizontalAlignment: Text.AlignHCenter }
            TextField {
              id: dayField
              width: parent.width
              horizontalAlignment: TextInput.AlignHCenter
              inputMethodHints: Qt.ImhDigitsOnly
              maximumLength: 2
              foreground: root.contentForeground
              font.family: root.contentFontFamily
              onTextChanged: root.clearFeedback()
              Keys.onReturnPressed: root.doConvert()
              Keys.onEnterPressed: root.doConvert()
            }
          }
        }

        Row {
          width: parent.width
          spacing: Style.space(8)

          Button {
            text: "Convert"
            iconText: "󰒟"
            bordered: true
            foreground: root.contentForeground
            fontFamily: root.contentFontFamily
            onClicked: root.doConvert()
          }

          Button {
            visible: !root.hasError && root.resultText !== "" && root.resultText !== "Enter a valid date"
            text: root.copied ? "Copied" : "Copy"
            iconText: root.copied ? "󰄬" : "󰆏"
            bordered: true
            foreground: root.contentForeground
            fontFamily: root.contentFontFamily
            onClicked: root.copyResult()
          }
        }

        Rectangle {
          visible: root.resultText !== ""
          width: parent.width
          height: visible ? resultTextItem.implicitHeight + Style.space(16) : 0
          radius: Style.cornerRadius
          color: root.hasError
            ? Qt.rgba(Color.critical.r, Color.critical.g, Color.critical.b, 0.12)
            : Qt.rgba(root.contentForeground.r, root.contentForeground.g, root.contentForeground.b, 0.08)

          Text {
            id: resultTextItem
            anchors.centerIn: parent
            width: parent.width - Style.space(16)
            text: root.resultText
            textFormat: Text.PlainText
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            color: root.hasError ? Color.critical : root.contentForeground
            font.family: root.contentFontFamily
            font.pixelSize: Style.font.body
            font.bold: !root.hasError
          }
        }

        Text {
          width: parent.width
          text: "Enter to convert · S to swap · Tab switches panels"
          textFormat: Text.PlainText
          horizontalAlignment: Text.AlignHCenter
          color: Qt.darker(root.contentForeground, 1.8)
          font.family: root.contentFontFamily
          font.pixelSize: Style.font.caption
          wrapMode: Text.Wrap
        }
      }
    }
  }
}
