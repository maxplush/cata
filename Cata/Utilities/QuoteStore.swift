import Foundation

struct Quote {
    let text: String
    let author: String
}

enum QuoteStore {
    static var today: Quote {
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return all[(day - 1) % all.count]
    }

    static let all: [Quote] = [
        // Lao Tzu / Tao Te Ching
        Quote(text: "Nature does not hurry, yet everything is accomplished.", author: "Lao Tzu"),
        Quote(text: "The journey of a thousand miles begins with a single step.", author: "Lao Tzu"),
        Quote(text: "Knowing others is wisdom. Knowing yourself is enlightenment.", author: "Lao Tzu"),
        Quote(text: "To the mind that is still, the whole universe surrenders.", author: "Lao Tzu"),
        Quote(text: "Life is a series of natural and spontaneous changes. Don't resist them.", author: "Lao Tzu"),
        Quote(text: "Simplicity, patience, compassion. These three are your greatest treasures.", author: "Lao Tzu"),
        Quote(text: "When you realize there is nothing lacking, the whole world belongs to you.", author: "Lao Tzu"),
        Quote(text: "Act without expectation.", author: "Lao Tzu"),
        Quote(text: "The key to growth is the introduction of higher dimensions of consciousness.", author: "Lao Tzu"),
        Quote(text: "Be careful what you water your dreams with.", author: "Lao Tzu"),

        // Alan Watts
        Quote(text: "The meaning of life is just to be alive. It is so plain and so obvious and so simple.", author: "Alan Watts"),
        Quote(text: "You are under no obligation to be the same person you were five minutes ago.", author: "Alan Watts"),
        Quote(text: "No valid plans for the future can be made by those who have no capacity for living now.", author: "Alan Watts"),
        Quote(text: "The only way to make sense out of change is to plunge into it, move with it, and join the dance.", author: "Alan Watts"),
        Quote(text: "Muddy water is best cleared by leaving it alone.", author: "Alan Watts"),
        Quote(text: "You are a function of what the whole universe is doing in the same way that a wave is a function of what the whole ocean is doing.", author: "Alan Watts"),
        Quote(text: "Problems that remain persistently insoluble should always be suspected as questions asked in the wrong way.", author: "Alan Watts"),
        Quote(text: "The art of living is neither careless drifting on the one hand nor fearful clinging on the other.", author: "Alan Watts"),

        // Marcus Aurelius
        Quote(text: "You have power over your mind, not outside events. Realize this, and you will find strength.", author: "Marcus Aurelius"),
        Quote(text: "Very little is needed to make a happy life; it is all within yourself, in your way of thinking.", author: "Marcus Aurelius"),
        Quote(text: "The impediment to action advances action. What stands in the way becomes the way.", author: "Marcus Aurelius"),
        Quote(text: "Waste no more time arguing what a good man should be. Be one.", author: "Marcus Aurelius"),
        Quote(text: "Confine yourself to the present.", author: "Marcus Aurelius"),
        Quote(text: "If it is not right, do not do it. If it is not true, do not say it.", author: "Marcus Aurelius"),
        Quote(text: "Receive without pride, relinquish without struggle.", author: "Marcus Aurelius"),
        Quote(text: "The soul becomes dyed with the color of its thoughts.", author: "Marcus Aurelius"),

        // Seneca
        Quote(text: "It is not that I am brave, it is that I am busy.", author: "Seneca"),
        Quote(text: "Begin at once to live, and count each separate day as a separate life.", author: "Seneca"),
        Quote(text: "We suffer more in imagination than in reality.", author: "Seneca"),
        Quote(text: "Luck is what happens when preparation meets opportunity.", author: "Seneca"),
        Quote(text: "Hang on to your youthful enthusiasms — you'll be able to use them better when you're older.", author: "Seneca"),
        Quote(text: "The whole future lies in uncertainty: live immediately.", author: "Seneca"),
        Quote(text: "No person has the power to have everything they want, but it is in their power not to want what they don't have.", author: "Seneca"),

        // Rick Rubin
        Quote(text: "The creative act is not performed by the artist alone. The audience co-creates.", author: "Rick Rubin"),
        Quote(text: "When we sit down each day and do our work, we become a conduit for the creative force in the universe.", author: "Rick Rubin"),
        Quote(text: "The best work is the work that surprises you.", author: "Rick Rubin"),
        Quote(text: "Awareness is the greatest agent for change.", author: "Rick Rubin"),
        Quote(text: "Everything is a choice. Every moment is an opportunity.", author: "Rick Rubin"),
        Quote(text: "The universe bends toward the artist who shows up every day.", author: "Rick Rubin"),
        Quote(text: "The work itself teaches you what you need to know.", author: "Rick Rubin"),
        Quote(text: "Deadlines and scarcity are friends of the creative process.", author: "Rick Rubin"),

        // Zen
        Quote(text: "Before enlightenment, chop wood, carry water. After enlightenment, chop wood, carry water.", author: "Zen proverb"),
        Quote(text: "The obstacle is the path.", author: "Zen proverb"),
        Quote(text: "If you are present, there is always something there.", author: "Shunryu Suzuki"),
        Quote(text: "In the beginner's mind there are many possibilities. In the expert's mind there are few.", author: "Shunryu Suzuki"),
        Quote(text: "When you do something, you should burn yourself completely, like a good bonfire, leaving no trace of yourself.", author: "Shunryu Suzuki"),
        Quote(text: "Wherever you are is called here, and you must treat it as a powerful stranger.", author: "David Whyte"),
        Quote(text: "Do not seek to follow in the footsteps of the wise. Seek what they sought.", author: "Matsuo Bashō"),
        Quote(text: "The quieter you become, the more you are able to hear.", author: "Rumi"),

        // Zhuangzi
        Quote(text: "Flow with whatever is happening and let your mind be free.", author: "Zhuangzi"),
        Quote(text: "Those who realize their folly are not true fools.", author: "Zhuangzi"),
        Quote(text: "A frog in a well cannot conceive of the ocean.", author: "Zhuangzi"),

        // Misc wisdom
        Quote(text: "Almost everything will work again if you unplug it for a few minutes, including you.", author: "Anne Lamott"),
        Quote(text: "A year from now you may wish you had started today.", author: "Karen Lamb"),
        Quote(text: "Do the difficult things while they are easy and do the great things while they are small.", author: "Lao Tzu"),
        Quote(text: "The present moment always will have been.", author: "Unknown"),
        Quote(text: "Routine, in an intelligent man, is a sign of ambition.", author: "W.H. Auden"),
        Quote(text: "We are what we repeatedly do. Excellence, then, is not an act, but a habit.", author: "Aristotle"),
        Quote(text: "Small disciplines repeated with consistency every day lead to great achievements gained slowly over time.", author: "John Maxwell"),
        Quote(text: "Be regular and orderly in your life so that you may be violent and original in your work.", author: "Gustave Flaubert"),
    ]
}
