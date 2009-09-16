namespace :merryresume do
  
  desc "process resumes"
  task :process => :environment do
    
    body = ""
    
    resumes = Resume.find(:all, :conditions => "paper_processed_at IS NULL")
    body << "*Nb of resumes processed* : #{resumes.size}\n\n"    
    
    resumes_processed = []
    resumes_not_processed = []
    
    for resume in resumes
      body << "* *#{resume.paper_file_name}*\n"
      
      if resume.paper.reprocess!
        resume.fill_content_with_paper_attached
        resume.save
        
        body << "** processed_at : #{resume.paper_processed_at}\n"
        
        if resume.content
          resumes_processed << resume
        else
          resumes_not_processed << resume
          body << "** *CONTENT IS NULL*\n"
        end
      end
    end
    
    if resumes_processed.size > 0 or resumes_not_processed.size > 0
      message = {
        :recipient => "admin",
        :subject => "Resumes processed",
        :body => body
      }
      
      puts "MESSAGE : #{message.inspect}"
      Batman.deliver_notifier(message)
    end
  end
  
  desc "resume init"
  task :bootstrap => [
    :create_sectors
  ]
    
  desc "create sectors"
  task :create_sectors => :environment do
    
    SECTORS = [
      { :code => "buy", :name => "buy"},
      { :code => "hr", :name => "hr"},
      { :code => "management", :name => "management"},
      { :code => "finance", :name => "finance"},
      { :code => "it", :name => "it"},
      { :code => "marketing", :name => "marketing"},
      { :code => "research", :name => "research"},
      { :code => "sell", :name => "sell"},
      { :code => "tourism", :name => "tourism"},
      { :code => "training", :name => "training"}
    ]
    
    for sector in SECTORS
      unless Sector.find_by_code(sector[:code])
        s = Sector.new(:code => sector[:code], :name => sector[:name])
        raise "Couldn't save sector #{sector[:name]}" if !s.save
        puts "INFO : sector #{sector[:name]} created"
      else
        puts "INFO : sector #{sector[:name]} already exist"
      end
    end
  end
  
  desc "update Campaign Monior"
  task :update_cm => :environment do
    users = User.find(:all)
    puts "Users nb : #{users.size}"
    n = 0
    users.each do |user|
      n += 1
      puts "#{n}. Subscribing : #{user.email}"
      user.signin_to_campaign_monitor
    end
  end
  
end