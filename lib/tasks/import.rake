namespace :import do  
  desc 'import images'
  task :images => :environment do
    location = File.join(File.dirname(__FILE__), "source")

    product = nil
    Dir[location+"/*"].sort_by{|s|s}.entries.each{|gender_dir|
      Dir[gender_dir+"/*"].sort_by{|s|s}.entries.each{|product_dir|

        product_name = File.basename(product_dir).strip.scan(/^[0-9]+/).first.to_s
        puts product_name
        product = Product.where(:code => product_name).first_or_create
        product.code = product_name
        product.title = product_name
        product.product_type = "Frame"
        product.price = 65
        product.gender = !gender_dir.downcase.index("female").nil? ? "Female" : (!gender_dir.downcase.index("male").nil? ? "Male" : "Unisex")
        product.save

        counter = 1
        if product && product.model_images.count == 0
          models = Dir[product_dir+"/model*/*"].entries.select{|s|(s=~/\.je?pg$/i)}.sort_by{|s|s}
          models = models.reverse if File.basename(File.dirname(models.first.to_s)).index("model_r") != nil
          models.each do |filename|
            puts "Model #{File.basename(filename)}"

            model_klass = product.gender == "Male" ? MaleModelImage : FemaleModelImage
            if product.gender == "Unisex"
              if !filename.index("_f").nil?
                model_klass = FemaleModelImage
              else
                model_klass = MaleModelImage
              end
            end

            model = model_klass.new
            model.position = counter
            model.product_id = product.id
            model.upload = File.open(filename)
            model.save

            counter+=1
          end
        end

        counter = 1
        if product
          Dir[product_dir+"/product/*/*"].entries.select{|s|(s=~/\.je?pg$/i)}.sort_by{|s|s}.each do |filename|
            color_name = File.basename(File.dirname(filename)).strip.split('_').last.capitalize
            color = Color.where(:name => color_name).first_or_create
            choice = Choice.by_color_name(color.name).where(:product_id => product.id).first_or_create

            product_image = ProductImage.new
            product_image.choice_id = choice.id
            product_image.product_id = product.id
            product_image.upload = File.open(filename)
            product_image.position = counter
            product_image.save

            counter += 1

            puts "Product #{File.basename(filename)}"
          end
        end

        if product
          Dir[product_dir+"/product/*/*"].entries.select{|s|(s=~/\.png$/i)}.sort_by{|s|s}.each do |filename|
            color_name = File.basename(File.dirname(filename)).strip.split('_').last.capitalize
            color = Color.where(:name => color_name).first_or_create

            fit_room_image = FitRoomImage.new
            fit_room_image.name = color.name
            fit_room_image.color_id = color.id
            fit_room_image.product_id = product.id
            fit_room_image.upload = File.open(filename)
            fit_room_image.save

            puts "Fit Room #{File.basename(filename)}"
          end
        end

        product = nil
      }

    }    
  end
end