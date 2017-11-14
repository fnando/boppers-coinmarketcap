# frozen_string_literal: true

require "bigdecimal"
require "boppers/coinmarketcap/version"

module Boppers
  class CoinMarketCap
    attr_reader :ticker, :operator, :expected_value,
                :already_notified, :interval, :unit

    def initialize(ticker:, operator:, value:, interval: 15, unit: "BTC")
      @ticker = ticker
      @operator = operator
      @expected_value = BigDecimal(value.to_s)
      @interval = interval
      @unit = unit
      @already_notified = false
    end

    def call
      ticker_info = fetch_ticker(ticker)
      current_value = BigDecimal(ticker_info.fetch("price_#{unit.downcase}"))
      public_send(operator, ticker_info, current_value)
    end

    def greater_than(ticker_info, current_value)
      if current_value > expected_value
        notify(ticker_info) unless already_notified
      else
        @already_notified = false
      end
    end

    def less_than(ticker_info, current_value)
      if current_value < expected_value
        notify(ticker_info) unless already_notified
      else
        @already_notified = false
      end
    end

    private def notify(ticker_info)
      price_btc = ticker_info["price_btc"]
      price_usd = ticker_info["price_usd"]
      change = (BigDecimal(ticker_info["percent_change_24h"])).to_f.round(2)
      volume = ticker_info["24h_volume_usd"]
      market_cap = ticker_info["market_cap_usd"]
      id = ticker_info["id"]

      title = "[COINMARKETCAP] #{ticker} traded as #{price_btc} ($#{price_usd})"
      message = [
        "24h Change: #{change}%",
        "Volume: $#{volume}",
        "Market Cap: $#{market_cap}",
        "",
        "https://coinmarketcap.com/currencies/#{id}/"
      ].join("\n")

      options = {
        telegram: {
          disable_web_page_preview: true,
          parse_mode: "HTML",
          title: "<b>#{title}</b>"
        }
      }

      Boppers.notify(:coinmarketcap,
                     title: title,
                     message: message,
                     options: options)
      @already_notified = true
    end

    private def fetch_ticker(ticker)
      response = Boppers::HttpClient.get do
        url "https://api.coinmarketcap.com/v1/ticker/?limit=0"
        options expect: 200
      end

      response.data.find {|ticker_info| ticker_info["symbol"] == ticker }
    end
  end
end
