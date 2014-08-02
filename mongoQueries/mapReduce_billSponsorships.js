//see http://docs.mongodb.org/manual/tutorial/write-scripts-for-the-mongo-shell/ 

var conn = new Mongo();
var db = conn.getDB("#statedrones-development")



map = function() {
 result = {open_states_id: this.open_states_id, bill: this.bill_id};
 partyNames = []
 for (i in this.sponsors) {
   partyNames.push(db.legislators.find({leg_id:this.sponsors[i].leg_id}).party)
 }
 for (i in partyNames) {
   result[partyName[i]] = 1
 }
 emit(this.open_states_id, result)
}


reduce = function(key, values) {
  //key is the openstates id, values are all the bills with that id. So only one.
  
  
  return ({key: values})
  //return something of the form:
  // {openstates_id: {bill: bill, state: state, party1:number, party2: number, ... }}
}


printjson(db.bills.mapReduce(map, reduce, {out:"test"}))