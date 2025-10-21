module challenge::hero;

use std::string::String;
use sui::object::{Self, ID, UID};
use sui::transfer;
use sui::tx_context::{Self, TxContext};

// ========= STRUCTS =========
public struct Hero has key, store {
    id: UID,
    name: String,
    image_url: String,
    power: u64,
}

public struct HeroMetadata has key, store {
    id: UID,
    timestamp: u64,
}

// ========= FUNCTIONS =========

#[allow(lint(self_transfer))]
public fun create_hero(name: String, image_url: String, power: u64, ctx: &mut TxContext) {
    // 1. Yeni bir Hero nesnesi oluşturuyoruz.
    let hero = Hero {
        id: object::new(ctx), // Benzersiz bir ID oluşturur.
        name: name,           // Parametre olarak gelen ismi atar.
        image_url: image_url, // Parametre olarak gelen resim linkini atar.
        power: power,         // Parametre olarak gelen gücü atar.
    };

    // 2. Oluşturulan kahramanı, bu işlemi çağıran kişinin cüzdanına gönderiyoruz.
    transfer::public_transfer(hero, tx_context::sender(ctx));

    // 3. Kahraman oluşturulduğunu takip etmek için bir metadata nesnesi yaratıyoruz.
    let metadata = HeroMetadata {
        id: object::new(ctx), // Metadata için de benzersiz bir ID.
        timestamp: tx_context::epoch_timestamp_ms(ctx), // İşlemin yapıldığı zaman damgası.
    };

    // 4. Metadata nesnesini "dondurarak" herkesin görebileceği, değiştirilemez bir kayıt haline getiriyoruz.
    transfer::freeze_object(metadata);
}

// ========= GETTER FUNCTIONS =========

public fun hero_power(hero: &Hero): u64 {
    hero.power
}

#[test_only]
public fun hero_name(hero: &Hero): String {
    hero.name
}

#[test_only]
public fun hero_image_url(hero: &Hero): String {
    hero.image_url
}

#[test_only]
public fun hero_id(hero: &Hero): ID {
    object::id(hero)
}