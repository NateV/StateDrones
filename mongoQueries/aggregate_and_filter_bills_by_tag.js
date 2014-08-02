db.bills.aggregate([
    {$match:{"tags.text":"government surveillance"}},
    {$unwind:"$tags"},
    {$group:{_id:"$tags.text", total:{$sum:1}}},
    {$sort:{total:-1}}
])