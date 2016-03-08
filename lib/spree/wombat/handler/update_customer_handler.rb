module Spree
  module Wombat
    module Handler
      class UpdateCustomerHandler < CustomerHandlerBase

        def process
          email = @payload["customer"]["email"]

          user = Spree.user_class.where(email: email).first

          raise "Can't find customer with email '#{email}'" if user.blank?
          # return response("Can't find customer with email '#{email}'", 500) unless user

          firstname = @payload["customer"]["firstname"]
          lastname = @payload["customer"]["lastname"]

          begin
            if user.ship_address
              user.ship_address.update_attributes(prepare_address(firstname, lastname, @payload["customer"]["shipping_address"]))
            elsif @payload["customer"]["shipping_address"]
              user.ship_address = Spree::Address.create!(prepare_address(firstname, lastname, @payload["customer"]["shipping_address"]))
            end

            if user.bill_address
              user.bill_address.update_attributes(prepare_address(firstname, lastname, @payload["customer"]["billing_address"]))
            elsif @payload["customer"]["billing_address"]
              user.bill_address = Spree::Address.create!(prepare_address(firstname, lastname, @payload["customer"]["billing_address"]))
            end
          rescue Exception => exception
            # return response(exception.message, 500)
            raise(exception)
          end

          self.try(:before_object_save, user)

          user.save

          response "Updated customer with #{email} and ID: #{user.id}"
        end

      end
    end
  end
end
