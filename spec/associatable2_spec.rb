require_relative '../arlite_orm'

describe 'Associatable' do
  before(:each) { DBConnection.reset }
  after(:each) { DBConnection.reset }

  before(:all) do
    class Cat < SQLObject
      belongs_to :human, foreign_key: :owner_id
      belongs_to :cat_house

      finalize!
    end

    class Human < SQLObject
      self.table_name = 'humans'

      has_many :cats, foreign_key: :owner_id
      belongs_to :house

      finalize!
    end

    class CatHouse < SQLObject
      has_many :cats

      finalize!
    end

    class House < SQLObject
      has_many :humans

      finalize!
    end
  end

  describe '::assoc_options' do
    it 'defaults to empty hash' do
      class TempClass < SQLObject
      end

      expect(TempClass.assoc_options).to eq({})
    end

    it 'stores `belongs_to` options' do
      cat_assoc_options = Cat.assoc_options
      human_options = cat_assoc_options[:human]

      expect(human_options).to be_instance_of(BelongsToOptions)
      expect(human_options.foreign_key).to eq(:owner_id)
      expect(human_options.class_name).to eq('Human')
      expect(human_options.primary_key).to eq(:id)
    end

    it 'stores options separately for each class' do
      expect(Cat.assoc_options).to have_key(:human)
      expect(Human.assoc_options).to_not have_key(:human)

      expect(Human.assoc_options).to have_key(:house)
      expect(Cat.assoc_options).to_not have_key(:house)
    end
  end

  describe '#has_one_through' do
    before(:all) do
      class Cat
        has_one_through :home, :human, :house

        self.finalize!
      end
    end

    let(:cat) { Cat.find(1) }

    it 'adds getter method' do
      expect(cat).to respond_to(:home)
    end

    it 'fetches associated `home` for a `Cat`' do
      house = cat.home

      expect(house).to be_instance_of(House)
      expect(house.address).to eq('26th and Guerrero')
    end
  end

  describe "#has_many_through" do
    describe "has_many through belongs_to" do
      before(:all) do
        class Human
          has_many_through :cat_houses, :cats, :cat_house
        end
      end

      let(:human) { Human.find(3) }

      it "adds method" do
        expect(human).to respond_to(:cat_houses)
      end

      it "fetches human's associated cat houses" do
        cat_houses = human.cat_houses
        expect(cat_houses.length).to eq(2)
        expect(cat_houses.first.color).to eq('orange')
        expect(cat_houses.first.id).to eq(3)
        expect(cat_houses.last.color).to eq('white')
        expect(cat_houses.last.id).to eq(4)
      end
    end
  end
end
