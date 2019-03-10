require_dependency "knock/application_controller"

module Knock
  class AuthTokenController < ApplicationController
    before_action :authenticate

    def create
      render json: auth_token, status: :created
    end

  private
    def authenticate
      logger.info("==== start authenticate auth_params[:password]: #{auth_params[:password]}===========")
      unless entity.present? && entity.authenticate(auth_params[:password])
        logger.info("==== entity.present? && entity.authenticate(auth_params[:password]) ===========")
        raise Knock.not_found_exception_class
      end
    end

    def auth_token
      if entity.respond_to? :to_token_payload
        logger.info("==== auth_token 11111 ===========")
        AuthToken.new payload: entity.to_token_payload
      else
        logger.info("==== auth_token 22222 ===========")
        AuthToken.new payload: { sub: entity.id }
      end
    end

    def entity
      @entity ||=
        if entity_class.respond_to? :from_token_request
          entity_class.from_token_request request
        else
          entity_class.find_by email: auth_params[:email]
        end
    end

    def entity_class
      entity_name.constantize
    end

    def entity_name
      self.class.name.scan(/\w+/).last.split('TokenController').first
    end

    def auth_params
      params.require(:auth).permit :email, :password
    end
  end
end
