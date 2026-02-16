import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import qs.Commons
import qs.Services.UI
import qs.Widgets
import qs.Modules.Cards

Item {
  id: root

  // SmartPanel
  readonly property var geometryPlaceholder: panelContainer

  property real contentPreferredWidth: 670 * Style.uiScaleRatio
  property real contentPreferredHeight: 270 * Style.uiScaleRatio

  readonly property bool allowAttach: true

  anchors.fill: parent

  Rectangle {
    id: panelContainer
    anchors.fill: parent
    color: "transparent"

    ColumnLayout {
      anchors {
        fill: parent
        margins: Style.marginL
      }
      spacing: Style.marginL

        Loader {
          active: Settings.data.location.weatherEnabled
          visible: active
          Layout.fillWidth: true
          sourceComponent: weatherCard;
          }
        }

          Component {
            id: weatherCard
            WeatherCardExtra {
                Layout.fillWidth: true
                forecastDays: 7
                showLocation: false
            }
        }
    }
}
