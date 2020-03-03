require_relative "domain_model/contact"
require_relative "schema/contact/create"
require_relative "schema/contact/update"

module ClientSuccess
  module Contact
    extend self

    def list_all(client_id:, connection:)
      response = connection.get(
        "/v1/clients/#{client_id}/contacts")

      response.body.map do |payload|
        DomainModel::Contact.new(
          payload.deep_transform_keys(&:underscore))
      end
    end

    def get_summary(client_id:, contact_id:, connection:)
      response = connection.get(
        "/v1/clients/#{client_id}/contacts/#{contact_id}")

      payload = response.body

      DomainModel::Contact.new(
        payload.deep_transform_keys(&:underscore))
    end

    def get_details(client_id:, contact_id:, connection:)
      response = connection.get(
        "/v1/clients/#{client_id}/contacts/#{contact_id}/details")

      payload = response.body

      DomainModel::Contact.new(
        payload.deep_transform_keys(&:underscore))
    end

    def create(client_id:, attributes:, connection:)
      body = Schema::Contact::Create[attributes]
        .transform_keys { |k| k.to_s.camelize(:lower) }
        .to_json

      response = connection.post(
        "/v1/clients/#{client_id}/contacts", body)

      payload = response.body

      DomainModel::Contact.new(
        payload.deep_transform_keys(&:underscore))
    end

    def update(id:, client_id:, attributes:, connection:)
      body = Schema::Contact::Update[attributes]
        .transform_keys { |k| k.to_s.camelize(:lower) }
        .to_json

      response = connection.put("/v1/clients/#{client_id}/contacts/#{id}/details", body)

      payload = response.body

      DomainModel::Contact.new(
        payload.deep_transform_keys(&:underscore))
    end

    def delete(id:, client_id:, connection:)
      connection.delete("/v1/clients/#{client_id}/contacts/#{id}")
    end

    def search_by_email(email:, connection:)
      search(term: email, connection: connection)
        .reject { |contact| contact["email"].nil? }
        .select { |contact| contact["email"].downcase == email.downcase }
    end

    def get_details_by_client_external_id_and_email(client_external_id:, email:, connection:)
      connection
        .get("/v1/contacts?clientExternalId=#{client_external_id}&email=#{CGI.escape(email)}")
        .body
    rescue connection.class::ParsingError
      nil
    end

    def search(term:, connection:)
      connection.get("/v1/contacts/search?term='#{term}'").body
    end
  end
end