require "routes/signup"
require "routes/sessions"
require "routes/equipos"

require "libs/mongo"
require "helpers"

describe "GET /equipos/{equipo_id}" do
  before(:all) do
    payload = { email: "Diana@gmail.com", password: "123" }
    result = Sessions.new.login(payload)
    @user_id = result.parsed_response["_id"]
  end

  context "obter unico equipo" do
    before(:all) do
      # dado que eu tenho um novo equipamento
      @payload = {
        thumbnail: Helpers::get_thumb("sanfona.jpg"),
        name: "Sanfona",
        category: "Outros",
        price: 499,
      }

      MongoDB.new.remove_equipo(@payload[:name], @user_id)

      # e eu tenho o id desse equipamento
      equipo = Equipos.new.create(@payload, @user_id)
      @equipo_id = equipo.parsed_response["_id"]

      # quando faço uma requisição get por id
      @result = Equipos.new.find_by_id(@equipo_id, @user_id)
    end

    it "deve retornar 200" do
      expect(@result.code).to eql 200
    end

    it "deve retornar o nome" do
      expect(@result.parsed_response).to include("name" => @payload[:name])
    end
  end

  context "equipo nao existe" do
    before(:all) do
      @result = Equipos.new.find_by_id(MongoDB.new.get_mongo_id, @user_id)
    end

    it "deve retornar 404" do
      expect(@result.code).to eql 404
    end
  end
end

describe "GET /equipos" do
  before(:all) do
    payload = { email: "Diana@gmail.com", password: "123" }
    result = Sessions.new.login(payload)
    @user_id = result.parsed_response["_id"]
  end
  
    context "obeter uma lista de equipamentos" do
      before(:all) do
        payloads = [
          {
            thumbnail: Helpers::get_thumb("sanfona.jpg"),
            name: "Sanfona",
            category: "Outros",
            price: 499,
          },
          {
            thumbnail: Helpers::get_thumb("conga.jpg"),
            name: "Conga",
            category: "Outros",
            price: 599,
          },
          {
            thumbnail: Helpers::get_thumb("trompete.jpg"),
            name: "Trompete",
            category: "Outros",
            price: 699,
          } 
      ]
        payloads.each do |payload|
          MongoDB.new.remove_equipo(payload[:name], @user_id)
          Equipos.new.create(payload, @user_id)
        end

        @result = Equipos.new.list(@user_id)
      end
      
      it "deve retornar 200" do
        expect(@result.code).to eql 200
      end

      it "deve retornar lista de equipos" do 
        expect(@result.parsed_response).not_to be_empty
        puts @result.parsed_response
        puts @result.parsed_response.class
      end
  end
end