module challenge::marketplace;

use challenge::hero::Hero;
use sui::coin::{Self, Coin};
use sui::object::{Self, ID, UID};
use sui::transfer;
use sui::tx_context::{Self, TxContext};
use sui::event;
use sui::sui::SUI;

// ========= ERRORS =========

const EInvalidPayment: u64 = 1;

// ========= STRUCTS =========

public struct ListHero has key, store {
    id: UID,
    nft: Hero,
    price: u64,
    seller: address,
}

// ========= CAPABILITIES =========

public struct AdminCap has key, store {
    id: UID,
}

// ========= EVENTS =========

public struct HeroListed has copy, drop {
    list_hero_id: ID,
    price: u64,
    seller: address,
    timestamp: u64,
}

public struct HeroBought has copy, drop {
    list_hero_id: ID,
    price: u64,
    buyer: address,
    seller: address,
    timestamp: u64,
}

// ========= FUNCTIONS =========

fun init(ctx: &mut TxContext) {
    // Admin yetkisini (AdminCap) oluşturup modülü yayınlayan kişiye gönderiyoruz.
    let admin_cap = AdminCap {
        id: object::new(ctx),
    };
    transfer::public_transfer(admin_cap, tx_context::sender(ctx));
}

public fun list_hero(nft: Hero, price: u64, ctx: &mut TxContext) {
    // Satışa çıkarılacak kahraman için bir listeleme nesnesi oluşturuyoruz.
    let list_hero = ListHero {
        id: object::new(ctx),
        nft: nft,
        price: price,
        seller: tx_context::sender(ctx),
    };

    // HeroListed olayını yayınlıyoruz.
    event::emit(HeroListed {
        list_hero_id: object::id(&list_hero),
        price: list_hero.price,
        seller: list_hero.seller,
        timestamp: tx_context::epoch_timestamp_ms(ctx),
    });

    // Listelenen kahramanı herkesin görebilmesi için paylaşıyoruz.
    transfer::share_object(list_hero);
}

#[allow(lint(self_transfer))]
public fun buy_hero(list_hero: ListHero, coin: Coin<SUI>, ctx: &mut TxContext) {
    // Listeleme nesnesini parçalarına ayırıyoruz.
    let ListHero { id, nft, price, seller } = list_hero;

    // Ödemenin doğru miktarda yapıldığını kontrol ediyoruz. Değilse, işlemi iptal et.
    assert!(coin::value(&coin) == price, EInvalidPayment);

    // Parayı (coin) satıcının cüzdanına gönderiyoruz.
    transfer::public_transfer(coin, seller);

    // NFT'yi (hero) alıcının cüzdanına gönderiyoruz.
    transfer::public_transfer(nft, tx_context::sender(ctx));

    // HeroBought olayını yayınlıyoruz.
    event::emit(HeroBought {
        list_hero_id: object::uid_to_inner(&id),
        price: price,
        buyer: tx_context::sender(ctx),
        seller: seller,
        timestamp: tx_context::epoch_timestamp_ms(ctx),
    });

    // Satış tamamlandığı için listeleme nesnesini siliyoruz.
    object::delete(id);
}

// ========= ADMIN FUNCTIONS =========

public fun delist(_: &AdminCap, list_hero: ListHero) {
    // Listeleme nesnesini parçalarına ayırıyoruz.
    let ListHero { id, nft, price: _, seller } = list_hero;
    
    // NFT'yi asıl sahibi olan satıcıya geri gönderiyoruz.
    transfer::public_transfer(nft, seller);

    // Listelemeyi siliyoruz.
    object::delete(id);
}

public fun change_the_price(_: &AdminCap, list_hero: &mut ListHero, new_price: u64) {
    // list_hero nesnesinin fiyatını yeni fiyatla güncelliyoruz.
    list_hero.price = new_price;
}

// ========= GETTER FUNCTIONS =========

#[test_only]
public fun listing_price(list_hero: &ListHero): u64 {
    list_hero.price
}

// ========= TEST ONLY FUNCTIONS =========

#[test_only]
public fun test_init(ctx: &mut TxContext) {
    let admin_cap = AdminCap {
        id: object::new(ctx),
    };
    transfer::transfer(admin_cap, ctx.sender());
}