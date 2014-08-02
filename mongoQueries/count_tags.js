db.bills.aggregate([{"$unwind":"$tags"},
    {"$group":{"_id":"$tags.text", "count":{"$sum":1}}}
  ])