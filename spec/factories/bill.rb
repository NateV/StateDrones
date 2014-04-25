FactoryGirl.define do
  factory :bill do  |f|
    f.title "A bill about things."
    f.state "NY"
    f.chamber "upper"
    f.summary "This bill is about important issues."
    f.bill_id "A001"
  end
end