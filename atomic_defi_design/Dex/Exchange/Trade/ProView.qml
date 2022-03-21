import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtGraphicalEffects 1.0
import Qt.labs.settings 1.0

import Qaterial 1.0 as Qaterial

import AtomicDEX.MarketMode 1.0
import AtomicDEX.TradingError 1.0

import "../../Components"
import "../../Constants"
import "../../Wallet"

import App 1.0

// Trade Form / Component import
import "Trading/"
import "Trading/Items/"

// OrderBook / Component import
import "OrderBook/" as OrderBook

// Best Order
import "BestOrder/" as BestOrder

// Orders (orders, history)
import "Orders/" as OrdersView

import "../../Screens"
import Dex.Themes 1.0 as Dex

import "../ProView"
import "../ProView/PlaceOrderForm" as PlaceOrderForm
import "../ProView/TradingInfo" as TradingInfo

RowLayout
{
    id: form

    property alias chart: chart
    property alias trInfo: tradingInfo
    property alias orderBook: orderBook
    property alias bestOrders: bestOrders
    property alias placeOrderForm: placeOrderForm

    spacing: 16

    function selectOrder(is_asks, coin, price, quantity, price_denom, price_numer, quantity_denom, quantity_numer, min_volume, base_min_volume, base_max_volume, rel_min_volume, rel_max_volume, base_max_volume_denom, base_max_volume_numer, uuid)
    {
        setMarketMode(!is_asks ? MarketMode.Sell : MarketMode.Buy)

        API.app.trading_pg.preffered_order = {
            "coin": coin,
            "price": price,
            "quantity": quantity,
            "price_denom": price_denom,
            "price_numer": price_numer,
            "quantity_denom": quantity_denom,
            "quantity_numer": quantity_numer,
            "min_volume": min_volume,
            "base_min_volume": base_min_volume,
            "base_max_volume": base_max_volume,
            "rel_min_volume": rel_min_volume,
            "rel_max_volume": rel_max_volume,
            "base_max_volume_denom": base_max_volume_denom,
            "base_max_volume_numer": base_max_volume_numer,
            "uuid": uuid
        }
        form_base.focusVolumeField()
    }

    Connections
    {
        target: exchange_trade
        function onBuy_sell_rpc_busyChanged()
        {
            if (buy_sell_rpc_busy)
                return

            const response = General.clone(buy_sell_last_rpc_data)
            if (response.error_code)
            {
                confirm_trade_modal.close()

                toast.show(qsTr("Failed to place the order"),
                           General.time_toast_important_error,
                           response.error_message)

                return
            }
            else if (response.result && response.result.uuid)
            {
                // Make sure there is information
                confirm_trade_modal.close()

                toast.show(qsTr("Placed the order"), General.time_toast_basic_info,
                           General.prettifyJSON(response.result), false)

                General.prevent_coin_disabling.restart()
                tabView.currentIndex = 1
            }
        }
    }

    ColumnLayout
    {
        Layout.alignment: Qt.AlignTop

        Layout.minimumWidth: 480
        Layout.maximumWidth: (!orderBook.visible && !bestOrders.visible) || (!placeOrderForm.visible) ? -1 : 735
        Layout.fillWidth: true

        Layout.fillHeight: true

        spacing: 20

        // Chart
        Chart
        {
            id: chart

            Layout.fillWidth: true

            Layout.minimumHeight: isCollapsed() ? 60 : 190
            Layout.maximumHeight: tradingInfo.isCollapsed() ? -1 : 360
            Layout.fillHeight: !isCollapsed()
        }

        // Ticker selectors.
        TickerSelectors
        {
            id: selectors

            Layout.fillWidth: true
            Layout.preferredHeight: 70
        }

        // Trading Informations
        TradingInfo.Main
        {
            id: tradingInfo

            Layout.fillWidth: true

            Layout.minimumHeight: isCollapsed() ? 60 : 380
            Layout.maximumHeight: chart.isCollapsed() ? -1 : 500
            Layout.fillHeight: !isCollapsed()
        }
    }

    ColumnLayout
    {
        Layout.minimumWidth: 353
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.alignment: Qt.AlignTop

        OrderBook.Vertical
        {
            id: orderBook

            Layout.fillWidth: true

            Layout.minimumHeight: isCollapsed() ? 70 : 365
            Layout.maximumHeight: bestOrders.visible && !bestOrders.isCollapsed() ? 536 : -1
            Layout.fillHeight: !isCollapsed()
        }

        // Best Orders
        BestOrder.List
        {
            id: bestOrders

            Layout.fillWidth: true

            Layout.minimumHeight: isCollapsed() ? 70 : 196
            Layout.fillHeight: !isCollapsed()
        }
    }

    // Place order form.
    PlaceOrderForm.Main
    {
        id: placeOrderForm

        Layout.minimumWidth: 302
        Layout.maximumWidth: 350
        Layout.fillWidth: true

        Layout.minimumHeight: 571
        Layout.fillHeight: true
    }

    ModalLoader
    {
        id: confirm_trade_modal
        sourceComponent: ConfirmTradeModal {}
    }
}
