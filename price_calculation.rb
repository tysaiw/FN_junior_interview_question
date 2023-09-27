require './models/campaign.rb'
require './models/order.rb'

# 計算規則
#
# 1. 消費未滿 $1,500, 則須增加 $60 運費
# 2. 若消費期間有超過兩個優惠活動，取最優者折扣 
# 3. 運費計算在優惠折抵之後
#
# Please implemenet the following methods.
# Additional helper methods are recommended.

class PriceCalculation
  FREE_SHIPMENT_THRESHOLD = 1500
  SHIPMENT_FEE = 60

  def initialize(order_id)
    @order = Order.find(order_id)
    raise Order::NotFound if @order.nil?
  end

  def total
    apply_discounts_and_fees(@order.price)
  end

  def free_shipment?
    @order.price >= FREE_SHIPMENT_THRESHOLD
  end

  private

  def find_best_campaign
    running_campaigns = Campaign.running_campaigns(@order.order_date)
    running_campaigns.max_by { |campaign| campaign.discount_ratio }
  end

  def apply_campaign(total, campaign)
    return total if campaign.nil?

    discount = (total * campaign.discount_ratio / 100.0).to_i
    total - discount
  end

  def add_shipment_fee(total)
    return total if free_shipment?

    total + SHIPMENT_FEE
  end

  def apply_discounts_and_fees(initial_total)
    best_campaign = find_best_campaign
    discounted_total = apply_campaign(initial_total, best_campaign)

    add_shipment_fee(discounted_total)
  end
end
