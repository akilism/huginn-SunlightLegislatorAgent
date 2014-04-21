require 'spec_helper'

describe Agents::SunlightLegislatorAgent do
  before do
    @default_options = {
      'api_key' => '12345',
      'legislator_bioguide_id' => "wxyz",
      'expected_update_period_in_days' => "2"
    }

    @legislator = {
      'legislator_bioguide_id' => 'G000555',
      'name' => 'Charles Schumer',
      'chamber' => 'Senate',
      'state_name' => 'New York',
      'twitter_id' => 'ChuckSchumer',
      'contact_form' => 'http://www.schumer.senate.gov/Contact/contact_chuck.cfm',
      'phone_number' => '202-224-6542',
      'party' => 'D'
    }

    @votes = [{
      'chamber' => 'house',
      'congress' => '113',
      'voter_ids' => {
        'wxyz' => 'yea',
        'G000555' => 'yea',
        'b12345' => 'yea'
      },
      'voted_at' => '2014-04-07T21:32:00Z',
      'vote_type' => 'passage',                
      'roll_type' => 'On Passage of the Bill',
      'roll_id' => 's107-2014',
      'question' => 'On the Motion for Attendance PN1182',
      'bill_id' => 'hr3979-113',
      'nomination_id' => 'PN1182-113',
      'required' => '1/2',
      'result' => 'Bill Passed',
      'source' => 'http://www.senate.gov/legislative/LIS/roll_call_votes/vote1132/vote_113_2_00101.xml',
      'url' => 'http://www.senate.gov/legislative/LIS/roll_call_lists/roll_call_vote_cfm.cfm?congress=113&session=2&vote=00101'
    }]

    @bills = [{
      'sponsor_bioguide_id' => 'K000367',
      'sponsor_name' => 'Amy Klobuchar',
      'sponsor_first_name' => 'Amy',
      'sponsor_last_name' => 'Klobuchar',
      'bill_id' => 'hr3979-113',
      'bill_type' => 's',
      'chamber' => 'senate',
      'committee_ids' => ['SSHR','SSFI'],
      'congress' => '113',
      'introduced_on' => '2014-03-27',
      'last_action_at' => '2014-03-27',
      'last_vote_at' => '2014-03-27',
      'enacted_as' => {
        'congress' => '113',
        'law_type' => 'public',
        'number' => '99'
      },
      'last_action' => {
        'type' => 'enacted',
        'acted_at' => '2010-03-23',
        'text' => 'Became Public Law No: 111-148.',
        'references' => ['hr3979-100']
      },
      'history' => {
          'active' => 'true',
          'active_at' => '2009-10-07T18:35:00Z',
          'house_passage_result' => 'pass',
          'house_passage_result_at' => '2010-03-22T02:48:00Z',
          'senate_cloture_result' => 'pass',
          'senate_cloture_result_at' => '2009-12-23',
          'senate_passage_result' => 'pass',
          'senate_passage_result_at' => '2009-12-24',
          'vetoed' => 'false',
          'awaiting_signature' => 'false',
          'enacted' => 'true',
          'enacted_at' => '2010-03-23'
      },
      'number' => '2169',
      'offical_title' => 'A bill to amend the Internal Revenue Code of 1986 to encourage teachers to pursue teaching science, technology, engineering, and mathematics subjects at elementary and secondary schools.',
      'popular_title' => 'National STEM Education Tax Incentive for Teachers Act of 2014',
      'short_title' => 'National STEM Education Tax Incentive for Teachers Act of 2014',
      'urls' => {
          'congress' => 'http://beta.congress.gov/bill/113th/senate-bill/2108',
          'govtrack' => 'https://www.govtrack.us/congress/bills/113/s2108',
          'opencongress' => 'http://www.opencongress.org/bill/s2108-113'
      },
      'keywords' => [ 'Abortion', 'Administrative law and regulatory procedures', 'Adoption and foster care' ],
      'summary' => 'Patient Protection and Affordable Care Act - Title I: Quality, Affordable Health Care for All Americans...',
      'summary_short' => 'Patient Protection and Affordable Care Act',
      'cosponsor_ids' => [ 'G000362' ]
    }]

    @agent = Agents::SunlightLegislatorAgent.new(:name => 'HuginnBot', :options => @default_options)
    @agent.user = users(:bob)
    @agent.save!

    stub.any_instance_of(Agents::SunlightLegislatorAgent).make_sunlight_request  do |path, fields|
      if path.include? 'votes'
        @votes
      elsif path.include? 'legislator'
        [ @legislator ]
      else
        @bills
      end 
    end
  end

  describe "#check" do
    it 'emits events immediately' do
      @agent.check
      @agent.events.count.should == 3
      @agent.events.last.payload['vote']['vote'].should == 'yea'
      @agent.events.last.payload['sponsored_bill'].should == nil
      @agent.events.last.payload['cosponsored_bill'].should == nil
      @agent.events.last.payload['legislator_bioguide_id'].should == 'wxyz'
      @agent.events.last.payload['twitter_id'].should == 'ChuckSchumer'
    end
  end
end