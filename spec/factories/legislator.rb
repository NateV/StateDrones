FactoryGirl.define do
  factory :legislator do |f|
    f.openstates_id "MD0002"
    f.state "MD"
    f.full_name "Joe Smith"
    f.district "89"
    f.party "Silly"
  end
end