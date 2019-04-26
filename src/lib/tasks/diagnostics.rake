begin
  namespace :diagnostics do
    desc 'Run all diagnostic tasks'
    task all: [:environment] do
      diagnostics_images
      diagnostics_entries
    end

    desc 'Check for missing images for pages'
    task images: [:environment] do
      diagnostics_images
    end

    desc 'Check for multiple identical entries on one page'
    task entries: [:environment] do
      diagnostics_entries
    end
  end
end

def diagnostics_images
  puts('Checking images')
  volumes = Search.all.collect(&:volume).uniq.sort
  volumes.each do |volume|
    pages = Search.where(volume: volume).collect(&:page).uniq.sort
    pages.each do |page|
      next if PageImage.where(volume: volume, page: page).any?

      puts("Volume #{volume} - missing image for page #{page}")
    end
  end
end

def diagnostics_entries
  puts('Checking entries')
  entries = Search.where('entry IS NOT NULL').all.collect(&:entry).uniq.sort
  entries.each do |entry|
    related_searches = Search.where(entry: entry)
    problems = []
    related_searches.each do |rs|
      next if Search.where(entry: rs.entry, page: rs.page).count == 1

      problems << rs.page
    end
    problems = problems.uniq
    next unless problems.any?

    puts("Entry: #{entry} appears multiple times on page(s) #{problems}")
  end
end
