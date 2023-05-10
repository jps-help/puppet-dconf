# @summary Valid dconf profile entries
type Dconf::DBEntries = Hash[
  String[1],                                                # The name of the database
  Struct[{
      'type'  => Enum['user', 'system', 'service', 'file'], # The type of database
      'order' => Optional[Integer[1]]                       # The order of the entry in the list
  }]
]
