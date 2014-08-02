console.log("testing?");
db.bills.aggregate({$group:{_id:"$state", total:{$sum:1}}},
                   {$sort:{total: -1}})