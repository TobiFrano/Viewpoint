module Viewpoint::EWS::Types
  class CalendarFolder
    include Viewpoint::EWS
    include Viewpoint::EWS::Types
    include Viewpoint::EWS::Types::GenericFolder

    # Fetch items between a given time period
    # @param [DateTime] start_date the time to start fetching Items from
    # @param [DateTime] end_date the time to stop fetching Items from
    def items_between(start_date, end_date, opts={})
      items do |obj|
        obj.restriction = { :and =>
          [
            {:is_greater_than_or_equal_to =>
              [
                {:field_uRI => {:field_uRI=>'calendar:Start'}},
                {:field_uRI_or_constant=>{:constant => {:value =>start_date}}}
              ]
            },
            {:is_less_than_or_equal_to =>
              [
                {:field_uRI => {:field_uRI=>'calendar:End'}},
                {:field_uRI_or_constant=>{:constant => {:value =>end_date}}}
              ]
            }
          ]
        }
      end
    end



    def items_between_including_recurring_occurrences(start_date, end_date, opts={})
      items_with_calendar_view do |obj|
          obj.calendar_view = { :start_date =>start_date, :end_date =>end_date}
      end
    end

    # Creates a new appointment
    # @param attributes [Hash] Parameters of the calendar item. Some example attributes are listed below.
    # @option attributes :subject [String]
    # @option attributes :start [Time]
    # @option attributes :end [Time]
    # @return [CalendarItem]
    # @see Template::CalendarItem
    def create_item(attributes, to_ews_create_opts = {})
      template = Viewpoint::EWS::Template::CalendarItem.new attributes
      template.saved_item_folder_id = {id: self.id, change_key: self.change_key}
      rm = ews.create_item(template.to_ews_create(to_ews_create_opts)).response_messages.first
      if rm && rm.success?
        CalendarItem.new ews, rm.items.first[:calendar_item][:elems].first
      else
        raise EwsCreateItemError, "Could not create item in folder. #{rm.code}: #{rm.message_text}" unless rm
      end
    end

    def delete_item(opts)
      ews.delete_item(opts)
    end

  end
end
