FactoryGirl.define do
  factory :bill do  |f|
    f.title "A bill about things."
    f.state "ar"
    f.chamber "upper"
    f.summary "This bill is about important issues."
    f.bill_id "HB 1904"
    f.session "2013"
  end
end