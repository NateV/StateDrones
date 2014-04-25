var map = function() {
    emit(this.state, 1);
    }

var reduce = function(key, values) {
    return values.length
    }


db.bills.mapReduce(map, reduce, {out: "bills_per_state"})