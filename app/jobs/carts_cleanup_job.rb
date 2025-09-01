class CartsCleanupJob < ApplicationJob
  queue_as :default

  def perform(*args)
    puts "--- Executando CartsCleanupJob ---"

    carts_to_abandon = Cart.inactive_for_3_hours
    puts "Encontrados #{carts_to_abandon.count} carrinhos para marcar como abandonados."
    carts_to_abandon.update_all(status: :abandoned, abandoned_at: Time.current)

    carts_to_remove = Cart.abandoned_for_7_days
    puts "Encontrados #{carts_to_remove.count} carrinhos abandonados para remover."
    carts_to_remove.destroy_all

    puts "--- CartsCleanupJob Concluído ---"
  end
end

