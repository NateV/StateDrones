db.bills.aggregate({$unwind:"$tags"},
                   {$group:{_id:"$tags.text", total:{$sum:1}}},
                   {$sort:{total:-1}}
)