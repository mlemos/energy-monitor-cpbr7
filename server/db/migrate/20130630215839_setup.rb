class Setup < ActiveRecord::Migration
  def up
  	create_table :medidas do |t|
      t.float     :irms
      t.float     :potencia
  		t.timestamps
  	end

  end

  def down
  	drop_table :medidas
  end
end
