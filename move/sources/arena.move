module challenge::arena;

use challenge::hero::{Self, Hero};
use sui::object::{Self, ID, UID};
use sui::transfer;
use sui::tx_context::{Self, TxContext};
use sui::event;

// ========= STRUCTS =========

public struct Arena has key, store {
    id: UID,
    warrior: Hero,
    owner: address,
}

// ========= EVENTS =========

public struct ArenaCreated has copy, drop {
    arena_id: ID,
    timestamp: u64,
}

public struct ArenaCompleted has copy, drop {
    winner_hero_id: ID,
    loser_hero_id: ID,
    timestamp: u64,
}

// ========= FUNCTIONS =========

public fun create_arena(hero: Hero, ctx: &mut TxContext) {
    // Arena nesnesini oluşturuyoruz.
    let arena = Arena {
        id: object::new(ctx),
        warrior: hero,
        owner: tx_context::sender(ctx),
    };

    // Arena oluşturulduğuna dair bir "event" (olay kaydı) yayınlıyoruz.
    event::emit(ArenaCreated {
        arena_id: object::id(&arena),
        timestamp: tx_context::epoch_timestamp_ms(ctx),
    });

    // Arenayı herkesin görebileceği ve etkileşime girebileceği şekilde paylaşıyoruz.
    transfer::share_object(arena);
}

#[allow(lint(self_transfer))]
public fun battle(hero: Hero, arena: Arena, ctx: &mut TxContext) {
    // Arena nesnesini parçalarına ayırarak içindeki bilgilere ulaşıyoruz.
    // Bu işlemden sonra 'arena' değişkeni yok olur, sadece parçaları kalır.
    let Arena { id, warrior, owner } = arena;
    
    // Saldıran kahramanın gücü, arenadaki kahramanın gücünden fazlaysa...
    if (hero::hero_power(&hero) > hero::hero_power(&warrior)) {
        // Kazanan ve kaybeden bilgilerini içeren olayı yayınla.
        event::emit(ArenaCompleted {
            winner_hero_id: object::id(&hero),
            loser_hero_id: object::id(&warrior),
            timestamp: tx_context::epoch_timestamp_ms(ctx)
        });

        // Her iki kahramanı da savaşı başlatan kişiye (saldırana) transfer et.
        transfer::public_transfer(hero, tx_context::sender(ctx));
        transfer::public_transfer(warrior, tx_context::sender(ctx));
    } else { // Eğer arenadaki kahramanın gücü daha fazlaysa veya eşitse...
        // Kazanan ve kaybeden bilgilerini içeren olayı yayınla.
        event::emit(ArenaCompleted {
            winner_hero_id: object::id(&warrior),
            loser_hero_id: object::id(&hero),
            timestamp: tx_context::epoch_timestamp_ms(ctx)
        });

        // Her iki kahramanı da arenanın sahibine transfer et.
        transfer::public_transfer(hero, owner);
        transfer::public_transfer(warrior, owner);
    };

    // Savaş bittiği için artık arenaya ihtiyaç yok. Arenayı yok et.
    object::delete(id);
}