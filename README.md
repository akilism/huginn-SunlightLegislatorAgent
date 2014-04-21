Huginn agent for following members of Congress.
------------------------------------------------
huginn-SunlightLegislatorAgent



The SunlightLegislatorAgent uses the Sunlight Foundation Congress API to track the actions of a legislator.

  **You need a Sunlight Foundation API Token:** [http://sunlightfoundation.com/api/](http://sunlightfoundation.com/api/)
 
  **You need to provide a** `legislator_bioguide_id` for the legislator you wish to keep tabs on. [You can search for them here.](http://legislator.wolvesintheserverroom.com/)


  The Agent takes the follow required options:
  * `api_key`: your application's API token
  * `legislator_bioguide_id`: the bioguide_id for the legislator
  * `expected_update_period_in_days`:  is maximum number of days that you would expect to pass between updates from this agent.


  It's events look like this: *(Where only either vote, sponsored_bill, or cosponsored_bill available depending on the type.)*

          {
            'legislator_bioguide_id' => 'G000555',
            'name' => 'Charles Schumer',
            'chamber' => 'Senate',
            'state_name' => 'New York',
            'twitter_id' => 'ChuckSchumer',
            'contact_form' => 'http://www.schumer.senate.gov/Contact/contact_chuck.cfm',
            'phone_number' => '202-224-6542',
            'party' => 'D',
            'type' => 'vote', 'sponsored_bill', or 'cosponsored_bill'
            'vote' => {
                'chamber' => 'house',
                'congress' => '113',
                'vote' => 'yea',
                'voted_at' => '2014-04-07T21:32:00Z',
                'vote_type' => 'passage',
                'roll_type' => 'On Passage of the Bill',
                'roll_id' => 's107-2014',
                'question' => 'On the Motion for Attendance PN1182',
                'bill_id' => 'hr3979-113',
                'nomination_id' => 'PN1182-113',
                'required' => '1/2',
                'result' => 'Bill Passed'
                'source' => 'http://www.senate.gov/legislative/LIS/roll_call_votes/vote1132/vote_113_2_00101.xml',
                'url' => 'http://www.senate.gov/legislative/LIS/roll_call_lists/roll_call_vote_cfm.cfm?congress=113&session=2&vote=00101'
              },
            'sponsored_bill' => {
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
                  'references' => []
                }
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
                    'opencongress'=> 'http://www.opencongress.org/bill/s2108-113'
                },
                'keywords' => [ 'Abortion', 'Administrative law and regulatory procedures', 'Adoption and foster care' ],
                'summary' => 'Patient Protection and Affordable Care Act - Title I: Quality, Affordable Health Care for All Americans...',
                'summary_short' => 'Patient Protection and Affordable Care Act',
                'cosponsor_ids' => [ 'G000362' ]
              },
            'cosponsored_bill' => # Same format as sponsored_bill.
          }
