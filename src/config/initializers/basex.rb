# Initialise user management for BaseX
# => Change admin default passoword
# => Create readOnly
# => Create createOnly

require "#{Rails.root}/lib/BaseXClient"

ENV['BASEX_URL'] = 'xmldb'

# Generate radnom passowords
password_length = 64
ENV['BASEX_READONLY'] = rand(36**password_length).to_s(36)
ENV['BASEX_CREATEONLY'] = rand(36**password_length).to_s(36)

# Change default admin password
begin
  session = BaseXClient::Session.new(ENV['BASEX_URL'], 1984, "admin", "admin")
  session.execute("create db xmldb")
  q = session.query("user:password('admin', '"+ENV['BASEX_ADMIN']+"')")
  q.execute()
  q.close()
  session.close
rescue Exception => e
  # log exception
  Rails.logger.error(e)
end

queryList =[
  "user:create('readOnly', '"+ENV['BASEX_READONLY']+"', 'read', '*')",
  "user:create('createOnly', '"+ENV['BASEX_CREATEONLY']+"', 'create', '*')"
]

for qStr in queryList
  # create session
  session = BaseXClient::Session.new(ENV['BASEX_URL'], 1984, "admin", ENV['BASEX_ADMIN'])
  begin
    # Create new user
    q = session.query(qStr)
    q.execute()
    q.close()
  rescue Exception => e
    # log exception
    Rails.logger.error(e)
  end
  # close session
  session.close
end
