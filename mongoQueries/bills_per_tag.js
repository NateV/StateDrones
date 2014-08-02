map = function() {
    this.tags.forEach(function(tag){
        emit(tag.text, 1)
        })
}

reduce = function(key, values) {
  return values.length
}

db.bills.mapReduce(map, reduce, {out: "bills_per_tag"})