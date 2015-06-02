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

    class House < SQLObject
      has_many :humans

      finalize!
    end

    class CatHouse < SQLObject
      has_many :cats

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

  describe '#belongs_to' do
    let(:breakfast) { Cat.find(1) }
    let(:devon) { Human.find(1) }

    it 'fetches `human` from `Cat` correctly' do
      expect(breakfast).to respond_to(:human)
      human = breakfast.human

      expect(human).to be_instance_of(Human)
      expect(human.fname).to eq('Devon')
    end

    it 'fetches `house` from `Human` correctly' do
      expect(devon).to respond_to(:house)
      house = devon.house

      expect(house).to be_instance_of(House)
      expect(house.address).to eq('26th and Guerrero')
    end

    it 'returns nil if no associated object' do
      stray_cat = Cat.find(5)
      expect(stray_cat.human).to eq(nil)
    end
  end

  describe '#has_many' do
    let(:ned) { Human.find(3) }
    let(:ned_house) { House.find(2) }

    it 'fetches `cats` from `Human`' do
      expect(ned).to respond_to(:cats)
      cats = ned.cats

      expect(cats.length).to eq(2)

      expected_cat_names = %w(Haskell Markov)
      2.times do |i|
        cat = cats[i]

        expect(cat).to be_instance_of(Cat)
        expect(cat.name).to eq(expected_cat_names[i])
      end
    end

    it 'fetches `humans` from `House`' do
      expect(ned_house).to respond_to(:humans)
      humans = ned_house.humans

      expect(humans.length).to eq(1)
      expect(humans[0]).to be_instance_of(Human)
      expect(humans[0].fname).to eq('Ned')
    end

    it 'returns an empty array if no associated items' do
      catless_human = Human.find(4)
      expect(catless_human.cats).to eq([])
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
