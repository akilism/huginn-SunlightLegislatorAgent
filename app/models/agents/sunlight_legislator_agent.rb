
module Agents
  class SunlightLegislatorAgent < Agent
    cannot_receive_events!

    default_schedule 'every_30m'

    API_URL = 'https://congress.api.sunlightfoundation.com'

    description <<-MD
      The SunlightLegislatorAgent uses the Sunlight Foundation Congress API to track the actions of a legislator.

      **You need a Sunlight Foundation API Token:** [http://sunlightfoundation.com/api/](http://sunlightfoundation.com/api/)

      **You need to provide a** `legislator_bioguide_id` for the legislator you wish to keep tabs on. [http://legislator.wolvesintheserverroom.com/](http://legislator.wolvesintheserverroom.com/)

      * `api_key`: your application's API token
      * `legislator_bioguide_id`: the bioguide_id for the legislator
      * `expected_update_period_in_days`:  is maximum number of days that you would expect to pass between updates from this agent.
    MD

    event_description <<-MD
      Events look like this:

          {
            `legislator_bioguide_id` => 'G000555',
            `name` => 'Charles Schumer',
            `chamber` => 'Senate',
            `state_name` => 'New York',
            `twitter_id` => 'ChuckSchumer',
            `contact_form` => 'http://www.schumer.senate.gov/Contact/contact_chuck.cfm',
            `phone_number` => '202-224-6542',
            `party` => 'D',
            `type` => 'vote', 'sponsored_bill', or 'cosponsored_bill'
            `vote` => {
                `chamber` => 'house',
                `congress` => '113',
                `vote` => 'yea',
                `voted_at` => '2014-04-07T21:32:00Z',
                `vote_type` => 'passage',
                `roll_type` => 'On Passage of the Bill',
                `roll_id` => 's107-2014',
                `question` => 'On the Motion for Attendance PN1182',
                `bill_id` => 'hr3979-113',
                `nomination_id` => 'PN1182-113',
                `required` => '1/2',
                `result` => 'Bill Passed'
                `source` => 'http://www.senate.gov/legislative/LIS/roll_call_votes/vote1132/vote_113_2_00101.xml',
                `url` => 'http://www.senate.gov/legislative/LIS/roll_call_lists/roll_call_vote_cfm.cfm?congress=113&session=2&vote=00101'
              },
            `sponsored_bill` => {
                `sponsor_bioguide_id` => 'K000367',
                `sponsor_name` => 'Amy Klobuchar',
                `sponsor_first_name` => 'Amy',
                `sponsor_last_name` => 'Klobuchar',
                `bill_id` => 'hr3979-113',
                `bill_type` => 's',
                `chamber` => 'senate',
                `committee_ids` => ['SSHR','SSFI'],
                `congress` => '113',
                `introduced_on` => '2014-03-27',
                `last_action_at` => '2014-03-27',
                `last_vote_at` => '2014-03-27',
                `enacted_as` => {
                  `congress` => '113',
                  `law_type` => 'public',
                  `number` => '99'
                },
                `last_action` => {
                  `type` => 'enacted',
                  `acted_at` => '2010-03-23',
                  `text` => 'Became Public Law No: 111-148.',
                  `references` => []
                }
                `history` => {
                    `active` => 'true',
                    `active_at` => '2009-10-07T18:35:00Z',
                    `house_passage_result` => 'pass',
                    `house_passage_result_at` => '2010-03-22T02:48:00Z',
                    `senate_cloture_result` => 'pass',
                    `senate_cloture_result_at` => '2009-12-23',
                    `senate_passage_result` => 'pass',
                    `senate_passage_result_at` => '2009-12-24',
                    `vetoed` => 'false',
                    `awaiting_signature` => 'false',
                    `enacted` => 'true',
                    `enacted_at` => '2010-03-23'
                },
                `number` => '2169',
                `offical_title` => 'A bill to amend the Internal Revenue Code of 1986 to encourage teachers to pursue teaching science, technology, engineering, and mathematics subjects at elementary and secondary schools.',
                `popular_title` => 'National STEM Education Tax Incentive for Teachers Act of 2014',
                `short_title` => 'National STEM Education Tax Incentive for Teachers Act of 2014',
                `urls` => {
                    `congress` => 'http://beta.congress.gov/bill/113th/senate-bill/2108',
                    `govtrack` => 'https://www.govtrack.us/congress/bills/113/s2108',
                    `opencongress`=> 'http://www.opencongress.org/bill/s2108-113'
                },
                `keywords` => [ 'Abortion', 'Administrative law and regulatory procedures', 'Adoption and foster care' ],
                `summary` => 'Patient Protection and Affordable Care Act - Title I: Quality, Affordable Health Care for All Americans...',
                `summary_short` => 'Patient Protection and Affordable Care Act',
                `cosponsor_ids` => [ 'G000362' ]
              },
            `cosponsored_bill` => # Same format as sponsored_bill.
          }
    MD

    def default_options
      {
        'api_key' => '',
        'legislator_bioguide_id' => '',
        'expected_update_period_in_days' => '2'
      }
    end

    def validate_options
      errors.add(:base, 'api_key is required.') unless options['api_key'].present?
      errors.add(:base, 'legislator_bioguide_id is required.') unless options['legislator_bioguide_id'].present?
      errors.add(:base, 'expected_update_period_in_days is required.') unless options['expected_update_period_in_days'].present?
    end

    def working?
      event_created_within?(options['expected_update_period_in_days']) && !recent_error_logs?
    end

    def check
      data_for_events = get_sunlight_updates(options['legislator_bioguide_id'])
      data_for_events.each do |event_data|
        create_event :payload => event_data
      end
    end


    ##################################################################################
    #
    # Function: get_sunlight_updates
    #
    # Parameters:
    #   legislator_bioguide_id - the bioguide id for the legislator to lookup.
    #
    # Returns:
    #   Array of Objects - Legislator events to create. Always includes the following fields :
    #   'legislator_bioguide_id', 'name', 'chamber', 'state_name', 'twitter_id',
    #   'contact_form', 'phone_number', 'party' and one of the following: 'vote',
    #   'sponsored_bill', or 'cosponsored_bill'
    #
    def get_sunlight_updates(legislator_bioguide_id)
      legislator = get_legislator_information(legislator_bioguide_id)

      events = []
      events += get_votes(legislator_bioguide_id, legislator)
      events += get_bills(legislator_bioguide_id, legislator, true)
      events += get_bills(legislator_bioguide_id, legislator, false)

      return events
    end


    ###############################################################
    #
    # Function: get_votes
    #
    # Call Sunlight Foundation API for a legislator's information
    #
    # Parameters:
    #   legislator_bioguide_id - the bioguide id for the legislator
    #   legislator - object containing legislator data.
    #
    # Returns:
    #   Array of vote_events.
    #
    def get_votes(legislator_bioguide_id, legislator)
      raw_votes = get_vote_information(legislator_bioguide_id)
      votes = format_votes(raw_votes, legislator_bioguide_id)

      events = []

      votes.each do |vote|
        vote_event = legislator.clone
        vote_event['vote'] = vote
        vote_event['type'] = 'vote'
        events << vote_event
      end

      return events
    end


    ###############################################################
    #
    # Function: get_bills
    #
    # Call Sunlight Foundation API for a legislator's information
    #
    # Parameters:
    #   legislator_bioguide_id - the bioguide id for the legislator
    #   legislator - object containing legislator data.
    #   is_sponsor - boolean - looking up sponsored or cosponsored bills
    #
    # Returns:
    #   Array of bill events.
    #
    def get_bills(legislator_bioguide_id, legislator, is_sponsor)
      events = []

      if is_sponsor
        raw_bills = get_bill_information(legislator_bioguide_id, is_sponsor)
        sponsored_bills = format_bills(raw_bills, legislator_bioguide_id)

        sponsored_bills.each do |sponsored_bill|
          sponsored_bill_event = legislator.clone
          sponsored_bill_event['sponsored_bill'] = sponsored_bill
          sponsored_bill_event['type'] = 'sponsored_bill'
          events << sponsored_bill_event
        end
      else
        raw_bills = get_bill_information(legislator_bioguide_id, is_sponsor)
        cosponsored_bills = format_bills(raw_bills, legislator_bioguide_id)

        cosponsored_bills.each do |cosponsored_bill|
          cosponsored_bill_event = legislator.clone
          cosponsored_bill_event['cosponsored_bill'] = cosponsored_bill
          cosponsored_bill_event['type'] = 'cosponsored_bill'
          events << cosponsored_bill_event
        end
      end

      return events
    end


    ###############################################################
    #
    # Function: get_legislator_information
    #
    # Call Sunlight Foundation API for a legislator's information
    #
    # Parameters:
    #   legislator_bioguide_id - the bioguide id for the legislator
    #
    # Returns:
    #   Object - The legislator information.
    #
    def get_legislator_information(legislator_bioguide_id)
      path = '/legislators?bioguide_id=' + legislator_bioguide_id
      fields = ['name', 'chamber', 'state_name', 'twitter_id', 'contact_form', 'phone_number', 'party']
      results = make_sunlight_request(path, fields)
      results[0]['legislator_bioguide_id'] = legislator_bioguide_id
      return results[0]
    end


    ###############################################################
    #
    # Function: get_vote_information
    #
    # Call Sunlight Foundation API for a legislator's vote information
    #
    # Parameters:
    #   legislator_bioguide_id - the bioguide id for the legislator
    #
    # Returns:
    #   Array of objects - The last 5 votes for the supplied
    #   legislator_bioguide_id.
    #
    def get_vote_information(legislator_bioguide_id)
      path = '/votes?voter_ids.' + legislator_bioguide_id + '__exists=true&order=voted_at'
      fields = ['chamber', 'congress', 'voted_at', 'voter_ids', 'vote_type', 'roll_type', 'roll_id', 'question', 'bill_id', 'nomination_id', 'required', 'result', 'source', 'url']

      return make_sunlight_request(path, fields)
    end


    def format_votes(results, legislator_bioguide_id)
      votes = []
      results.each do |result|
        result['legislator_bioguide_id'] = legislator_bioguide_id

        # If the voter_ids array is present then pull out the vote that was cast.
        if result['voter_ids'].present?
          voter_ids = result['voter_ids']
          result['vote'] = voter_ids[legislator_bioguide_id]

          # No longer need this array of all the votes.
          result.delete('voter_ids')
        end

        if !is_in_memory(result, 'vote')
          votes << result
          add_to_memory(result, 'vote')
        end
      end

      return votes
    end


    ######################################################################
    #
    # Function: get_bill_information
    #
    # Call Sunlight Foundation API for a legislator's bill information
    #
    # Parameters:
    #   legislator_bioguide_id - the bioguide id for the legislator
    #   is_sponsor - is this the sponsor of the bill
    #
    # Returns:
    #   Array of objects- The last 5 sponsor or cosponsor bill actions for
    #   the supplied legislator_bioguide_id.
    #
    def get_bill_information(legislator_bioguide_id, is_sponsor)
      type = ''
      if is_sponsor
        path = '/bills?sponsor_id=' + legislator_bioguide_id + '&order=last_action_at'
        type = 'sponsored_bill'
      else
        path = '/bills?cosponsor_ids__in=' + legislator_bioguide_id + '&order=last_action_at'
        type = 'cosponsored_bill'
      end

      fields = ['sponsor', 'bill_id', 'bill_type', 'chamber', 'committee_ids', 'congress', 'introduced_on', 'last_action_at', 'last_vote_at', 'enacted_as', 'congress', 'law_type', 'number', 'last_action', 'history', 'number', 'official_title', 'popular_title', 'short_title', 'urls', 'keywords', 'summary', 'summary_short', 'cosponsor_ids']

      return make_sunlight_request(path, fields)
    end


    def format_bills(results, legislator_bioguide_id)
      bills = []
      results.each do |result|
        result['legislator_bioguide_id'] = legislator_bioguide_id

        # If the sponsor object is present then pull out the bill's sponsor data.
        if result['sponsor'].present?
          sponsor = result['sponsor']
          result['sponsor_name'] = sponsor['first_name'] + ' ' + sponsor['last_name']
          result['sponsor_first_name'] = sponsor['first_name']
          result['sponsor_last_name'] = sponsor['last_name']
          result['sponsor_bioguide_id'] = sponsor['bioguide_id']

          # No longer need this object of sponsor information.
          result.delete('sponsor')
        end

        if !is_in_memory(result, type)
          bills << result
          add_to_memory(result, type)
        end
      end

      return bills
    end


    #################################################
    # Function: is_in_memory
    #
    # Checks the memory for a value.
    #
    # Parameters:
    #   value - the value to check for in the memory
    #   type - they type of the value to check
    #
    # Returns:
    #   bool - true if found
    #
    def is_in_memory(value, type)
      memory[type] ||= []
      values = memory[type]

      if type == "vote"
        memory_index = values.find_index { |mem_value| mem_value['voted_at'] == value['voted_at'] && mem_value['roll_id'] == value['roll_id'] }
      end

      if type == 'sponsored_bill'
        memory_index = values.find_index { |mem_value| mem_value['last_action_at'] == value['last_action_at'] && mem_value['bill_id'] == value['bill_id'] }
      end

      if type == 'cosponsored_bill'
        memory_index = values.find_index { |mem_value| mem_value['last_action_at'] == value['last_action_at'] && mem_value['bill_id'] == value['bill_id'] }
      end

      return nil ^ memory_index
    end


    ###############################
    #
    # Function: add_to_memory
    #
    # Adds a value to the memory.
    #
    # Parameters:
    #   value - the value to add to the memory
    #   type - the type of the value to save
    #
    def add_to_memory(value, type)
      memory[type] ||= []

      if memory[type].length == 5
        memory[type] = memory[type].slice 0...4
      end

      memory[type] << value
    end


    ##########################################################################
    #
    # Function: make_sunlight_request
    #
    # Makes a request to the Sunlight Foundation Congress API.
    #
    # Parameters:
    #   path - the Sunlight Foundation API path to call.
    #   fields_to_return - the fields to return.
    #
    # Returns:
    #   Array - results from the Sunlight Foundation API response.
    #
    def make_sunlight_request(path, fields_to_return)
      # flatten the array of fields to request into a comma separated string.
      fields = fields_to_return.reduce { |fields_to_get, field| fields_to_get += ',' + field }

      path += '&per_page=5&fields=' + fields

      response = HTTParty.get(API_URL + path, :headers => { 'X-APIKEY' => options['api_key'], "User-Agent" => 'huginn' })

      return response['results']
    end

  end
end
