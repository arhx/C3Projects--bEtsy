class OrdersController < ApplicationController
  before_action :find_order, only: [:show]
  before_action :find_order_item, only: [:qty_decrease, :qty_increase]

  def find_order
    @order = Order.find(params[:id])
  end

  def find_order_item
    @order_item = OrderItem.find(params[:id])
  end

  def new
    # triggered by the 'add to cart' button on Products#show
  end

  def create
    # see :new
  end

  def show
    @order_items = @order.order_items
  end

  def qty_decrease
    @order_item.quantity -= 1
    @order_item.save

    redirect_to :back
  end

  def qty_increase
    @order_item.quantity += 1
    @order_item.save

    redirect_to :back
  end


end
