require 'spec_helper'

describe SmartMeta do
  include SmartMeta

  before(:all) do
    ['en', 'koolaid'].each do |lang|
      I18n.load_path << File.expand_path(File.join(File.dirname(__FILE__), "languages/#{lang}.yml"))
    end
  end

  describe 'smart_meta_for' do
    it 'can handle instance variables' do
      @name = "Jeff"
      @color = "blue"

      stub!(:params).and_return(:action => "show", :controller => "users")
      smart_meta_for(:title).should == "Jeff has blue eyes"
    end

    it 'can handle using other accessible methods' do
      def an_animal
        "panda"
      end

      stub!(:params).and_return(:action => "show", :controller => "animals")
      I18n.backend.stub!(:lookup, "animals.show.title").and_return("The {{an_animal.pluralize}} are cute!")

      smart_meta_for(:title).should == "The pandas are cute!"
    end

    it "works with multiple locales" do
      @name = "Jeff"
      @color = "blue"

      stub!(:params).and_return(:action => "show", :controller => "users")

      I18n.locale = :koolaid
      smart_meta_for(:title).should == "OH YEAH!!!! Jeff has blue eyes... OH YEAH!!!!"

      I18n.locale = :en
      smart_meta_for(:title).should == "Jeff has blue eyes"
    end

    it "can send multiple messages to an object" do
      @controller = "dinosaurs"
      mock_dino = mock(:name => "Grizzly-T-Rex")
      @dinosaurs = [mock_dino, mock]

      stub!(:params).and_return(:action => "index", :controller => "dinosaurs")
      I18n.backend.stub!(:lookup, "dinosaurs.index.title").and_return("{{@dinosaurs.first.name}} is the scariest of all the {{@controller}}!")

      smart_meta_for(:title).should == "Grizzly-T-Rex is the scariest of all the dinosaurs!"
    end

    it 'returns nil if it cannot match the translation' do
      stub!(:params).and_return(:action => "something", :controller => "something else")
      smart_meta_for(:title).should be_nil
    end
  end

  [:title, :keywords, :description].each do |kind|
    describe "smart_#{kind}" do
      it "calls smart_meta_for with :#{kind}" do
        should_receive(:smart_meta_for).with(kind)

        self.send(:"smart_#{kind}")
      end
    end
  end

  it 'allows you to use custom kinds' do
    stub!(:params).and_return(:action => "index", :controller => "dinosaurs")
    should_receive(:translation_for).with('dinosaurs.index.robots')
    smart_meta_for("robots")
  end
end
