module Spree
  module Wombat
    module Handler
      class AddCustomerHandler < CustomerHandlerBase

        def process
          email = @payload["customer"]["email"]
          if Spree.user_class.where(email: email).count > 0
            return response "Customer with email '#{email}' already exists!", 500
          end

          user = Spree.user_class.new(email: email)

          firstname = @payload["customer"]["firstname"]
          lastname = @payload["customer"]["lastname"]

          user.firstname = firstname
          user.lastname = lastname
          user.netsuite_customer_id = @payload["customer"]["internal_id"]

          user.save(validate: false)

          begin
            user.ship_address = Spree::Address.create!(prepare_address(firstname, lastname, @payload["customer"]["shipping_address"]))
            user.bill_address = Spree::Address.create!(prepare_address(firstname, lastname, @payload["customer"]["billing_address"]))
          rescue Exception => exception
            # return response(exception.message, 500)
            raise exception
          end

          user.save

          response "Added new customer with #{email} and ID: #{user.id}"

          user
        end

      end
    end
  end
end
