import '../models/story_entry.dart';

/// Local fallback data — used when the backend isn't reachable yet, or
/// once it's live, whenever it returns an empty list. Same 47
/// milestones you'll eventually seed into Django via /admin/.
///
/// NOTE: these descriptions are written in original wording, not copied
/// from any brand's own site copy — same dates, people, and models, but
/// reworded from scratch so this data is safe to ship in your app.
const List<StoryEntry> storyEntries = [
  // ---- 1890-1910 ----
  StoryEntry(
    id: '1891',
    year: '1891',
    eraKey: 'e1890',
    description:
        'Bob Walker Smith and Albert Eadie buy George Townsend & Co., a '
        'long-established Redditch needle maker that had recently branched '
        'into bicycles.',
  ),
  StoryEntry(
    id: '1893',
    year: '1893',
    eraKey: 'e1890',
    description:
        'A contract to supply precision parts to the Royal Small Arms '
        'Factory prompts a rename to Enfield Manufacturing Company. Their '
        'bicycles become "Royal Enfield," alongside the "Made Like A Gun" '
        'slogan.',
  ),
  StoryEntry(
    id: '1898',
    year: '1898',
    eraKey: 'e1890',
    description:
        'Bob Walker Smith designs the firm\'s first motorised vehicle — a '
        'quadricycle with a small De Dion engine. The company settles on '
        'the name The Enfield Cycle Co. Ltd., used in Britain for the next '
        'seven decades.',
  ),
  StoryEntry(
    id: '1900',
    year: '1900',
    eraKey: 'e1890',
    description:
        'A Royal Enfield quadricycle takes silver at the first 1,000 Mile '
        'Reliability Trial, a gruelling London–Edinburgh–London route that '
        'helps convince the British public motorised transport is viable.',
  ),
  StoryEntry(
    id: '1901',
    year: '1901',
    eraKey: 'e1890',
    description:
        'The first Royal Enfield motorcycle is built, designed by Bob '
        'Walker Smith and Jules Gobiet, and debuts at the Stanley Cycle '
        'Show. Priced at £50, its rear wheel is driven by a long leather '
        'belt.',
  ),
  StoryEntry(
    id: '1904',
    year: '1904',
    eraKey: 'e1890',
    description:
        'John Paul Burney wins what is believed to be the first documented '
        'motorcycle road race, riding a 350cc belt-driven Royal Enfield '
        '200 rough miles across Ireland, 45 minutes clear of second place.',
  ),
  StoryEntry(
    id: '1909',
    year: '1909',
    eraKey: 'e1890',
    description:
        'Royal Enfield\'s first V-twin, built around a Swiss Motosacoche '
        'engine, launches at the Stanley Cycle Show and goes on to strong '
        'results in trials the following year.',
  ),

  // ---- 1911-1930 ----
  StoryEntry(
    id: '1914',
    year: '1914',
    eraKey: 'e1911',
    description:
        'As Britain enters the First World War, the 770cc V-twin becomes '
        'the company\'s priority model, supplied to several Allied armies '
        'through the conflict.',
  ),
  StoryEntry(
    id: '1924',
    year: '1924',
    eraKey: 'e1911',
    description:
        'The range grows to eight models, including the Sports Model 351 '
        '— the first 350cc OHV four-stroke Royal Enfield with a '
        'foot-operated gear change — alongside a step-through model built '
        'for women riders.',
  ),
  StoryEntry(
    id: '1925',
    year: '1925',
    eraKey: 'e1911',
    description:
        'A serious fire breaks out at the 18-acre Redditch factory; the '
        'company\'s own fire brigade keeps it from spreading through the '
        'whole site.',
  ),
  StoryEntry(
    id: '1928',
    year: '1928',
    eraKey: 'e1911',
    description:
        'Royal Enfield moves from flat fuel tanks to the more modern '
        'saddle-tank style and becomes an early adopter of centre-sprung '
        'girder front forks.',
  ),
  StoryEntry(
    id: '1930',
    year: '1930',
    eraKey: 'e1911',
    description:
        'The decade opens with an eleven-model range, from a 225cc '
        'two-stroke up to a 976cc V-twin, alongside new dry-sump 350 and '
        '500cc machines.',
  ),

  // ---- 1931-1950 ----
  StoryEntry(
    id: '1932',
    year: '1932',
    eraKey: 'e1931',
    description:
        'The Bullet is born, offered in 250, 350 and 500cc form with '
        'sloping engines and twin-port heads. The 500, with a four-valve '
        'head, is capable of 90mph.',
  ),
  StoryEntry(
    id: '1933_smith',
    year: '1933',
    eraKey: 'e1931',
    description:
        'Co-founder Bob Walker Smith passes away; his son, Major Frank '
        'Smith, already joint Managing Director, takes full control of the '
        'company.',
  ),
  StoryEntry(
    id: '1933_cycar',
    year: '1933',
    eraKey: 'e1931',
    description:
        'The Model Z "Cycar" goes on sale — a 148cc two-stroke commuter '
        'bike with a fully enclosed engine and leg shields for bad-weather '
        'riding.',
  ),
  StoryEntry(
    id: '1936',
    year: '1936',
    eraKey: 'e1931',
    description:
        'The 500cc Bullet is reworked with an upright, four-valve engine; '
        'a special-order sports version with a bronze cylinder head is '
        'also offered.',
  ),
  StoryEntry(
    id: '1943',
    year: '1943',
    eraKey: 'e1931',
    description:
        'Over 55,000 military motorcycles are built during WWII, including '
        'the tiny 125cc "Flying Flea," designed to be parachuted behind '
        'enemy lines alongside airborne troops, notably around D-Day.',
  ),
  StoryEntry(
    id: '1948',
    year: '1948',
    eraKey: 'e1931',
    description:
        'A 350cc Bullet prototype with oil-damped swinging-arm rear '
        'suspension is shown at the Colmore Cup Trial; two Bullets help '
        'Britain take team gold at that year\'s International Six Days '
        'Trial in Italy.',
  ),

  // ---- 1951-1970 ----
  StoryEntry(
    id: '1952_brittain',
    year: '1952',
    eraKey: 'e1951',
    description:
        'Works rider Johnny Brittain wins the Scottish Six Days Trial on '
        'his 350cc Bullet — a bike now preserved in Britain\'s National '
        'Motorcycle Museum.',
  ),
  StoryEntry(
    id: '1952_army',
    year: '1952',
    eraKey: 'e1951',
    description:
        'The Indian Army orders hundreds of 350 Bullets for border patrol '
        'duty in Kashmir and Rajasthan, impressed by how well they handle '
        'difficult terrain.',
  ),
  StoryEntry(
    id: '1955',
    year: '1955',
    eraKey: 'e1951',
    description:
        'Redditch partners with Madras Motors to form Enfield India, and '
        'work begins on a dedicated factory at Tiruvottiyur, near Madras.',
  ),
  StoryEntry(
    id: '1956',
    year: '1956',
    eraKey: 'e1951',
    description:
        'The Tiruvottiyur factory opens, initially assembling Bullets '
        'shipped from England as kits before production gradually moves '
        'entirely to India.',
  ),
  StoryEntry(
    id: '1957',
    year: '1957',
    eraKey: 'e1951',
    description:
        'Johnny Brittain wins the Scottish Six Days Trial again and tops '
        'the British trials championship; the 250cc Crusader, with unit '
        'construction and coil ignition, launches in Britain.',
  ),
  StoryEntry(
    id: '1964',
    year: '1964',
    eraKey: 'e1951',
    description:
        'The Continental GT café racer launches, proven by journalists '
        'riding one 1,000 miles from John O\'Groats to Land\'s End — '
        'including laps of Silverstone — in under 24 hours.',
  ),

  // ---- 1971-1990 ----
  StoryEntry(
    id: '1977',
    year: '1977',
    eraKey: 'e1971',
    description:
        'Royal Enfield India begins exporting the 350cc Bullet to the UK '
        'and Europe, quickly building a following among classic-motorcycle '
        'enthusiasts.',
  ),
  StoryEntry(
    id: '1989',
    year: '1989',
    eraKey: 'e1971',
    description:
        'A new 24bhp 500cc Bullet launches, aimed mainly at export markets '
        'in Classic, Deluxe and Superstar trims.',
  ),

  // ---- 1991-2010 ----
  StoryEntry(
    id: '1993',
    year: '1993',
    eraKey: 'e1991',
    description:
        'Enfield India builds the Enfield Diesel — the only mass-produced '
        'diesel motorcycle ever made — followed by the load-hauling Taurus '
        'variant for agricultural use.',
  ),
  StoryEntry(
    id: '1994',
    year: '1994',
    eraKey: 'e1991',
    description:
        'The Eicher Group acquires Enfield India, renaming it Royal '
        'Enfield Motors Limited and refocusing the brand solely on '
        'mid-size motorcycles.',
  ),
  StoryEntry(
    id: '1997',
    year: '1997',
    eraKey: 'e1991',
    description:
        'Forty Bullet Club riders reach Khardung La in Ladakh, one of the '
        'world\'s highest motorable passes, setting the template for what '
        'becomes the annual Himalayan Odyssey.',
  ),
  StoryEntry(
    id: '2001_engine',
    year: '2001',
    eraKey: 'e1991',
    description:
        'A redesigned all-aluminium 350cc "A350" Bullet engine, developed '
        'with Austria\'s AVL, enters production at a new plant near '
        'Jaipur.',
  ),
  StoryEntry(
    id: '2001_daredevils',
    year: '2001',
    eraKey: 'e1991',
    description:
        'The Indian Army\'s Daredevils display team form a 201-man human '
        'pyramid across ten Bullets and ride it more than 200 metres, '
        'setting a world record.',
  ),
  StoryEntry(
    id: '2002',
    year: '2002',
    eraKey: 'e1991',
    description:
        'The Thunderbird cruiser launches with Royal Enfield\'s first '
        'five-speed gearbox since the 1960s; over 1,000 owners gather in '
        'Redditch for a club reunion.',
  ),
  StoryEntry(
    id: '2004',
    year: '2004',
    eraKey: 'e1991',
    description:
        'The Electra X, an export Bullet with a 500cc alloy engine, goes '
        'on sale, while the Bullet Machismo is rated a top cruiser in an '
        'owner survey.',
  ),

  // ---- 2011-2025 ----
  StoryEntry(
    id: '2011',
    year: '2011',
    eraKey: 'e2011',
    description:
        'Riders worldwide are invited on the first "One Ride," which '
        'becomes an annual tradition; the company buys land at Oragadam '
        'for a new factory and runs its first organised ride across the '
        'Nepal border.',
  ),
  StoryEntry(
    id: '2012',
    year: '2012',
    eraKey: 'e2011',
    description:
        'The all-black Thunderbird 500 becomes Royal Enfield\'s first '
        'highway cruiser, launching as the Tiruvottiyur plant hits a '
        'production record of 113,000 motorcycles for the year.',
  ),
  StoryEntry(
    id: '2013_oragadam',
    year: '2013',
    eraKey: 'e2011',
    description:
        'Manufacturing begins at the new Oragadam plant, with a Classic '
        '500 Desert Storm as the first bike off the line at this '
        'robotics-equipped factory.',
  ),
  StoryEntry(
    id: '2013_gt',
    year: '2013',
    eraKey: 'e2011',
    description:
        'Almost 50 years after its first café racer, Royal Enfield '
        'reintroduces the Continental GT with a Harris Performance frame '
        'and 535cc engine, bringing café racers to the Indian market for '
        'the first time.',
  ),
  StoryEntry(
    id: '2015_harris',
    year: '2015',
    eraKey: 'e2011',
    description:
        'Royal Enfield acquires British design house Harris Performance to '
        'strengthen its engineering and product-design capabilities.',
  ),
  StoryEntry(
    id: '2015_na',
    year: '2015',
    eraKey: 'e2011',
    description:
        'Royal Enfield North America is established in Milwaukee, '
        'Wisconsin — the brand\'s first direct distribution business '
        'outside India.',
  ),
  StoryEntry(
    id: '2016',
    year: '2016',
    eraKey: 'e2011',
    description:
        'The Himalayan launches — Royal Enfield\'s first purpose-built '
        'adventure motorcycle, with a new 411cc engine and long-travel '
        'suspension for genuinely rough terrain.',
  ),
  StoryEntry(
    id: '2017_uktc',
    year: '2017',
    eraKey: 'e2011',
    description:
        'The UK Technology Centre opens near Leicester, with over 170 '
        'engineers and designers focused on R&D and long-term product '
        'strategy.',
  ),
  StoryEntry(
    id: '2017_vallam',
    year: '2017',
    eraKey: 'e2011',
    description:
        'A third factory begins production at Vallam Vadagal, near '
        'Chennai, dedicated to building 350cc models.',
  ),
  StoryEntry(
    id: '2017_twins',
    year: '2017',
    eraKey: 'e2011',
    description:
        'The 650cc Interceptor and Continental GT twins debut at EICMA and '
        'Rider Mania; the first Royal Enfield Garage Café opens in Goa.',
  ),
  StoryEntry(
    id: '2018_pegasus',
    year: '2018',
    eraKey: 'e2011',
    description:
        'The Classic 500 Pegasus, honouring the WWII Flying Flea, launches '
        'at the Imperial War Museum; its 250-unit India allocation sells '
        'out in under three minutes.',
  ),
  StoryEntry(
    id: '2018_bonneville',
    year: '2018',
    eraKey: 'e2011',
    description:
        '18-year-old racer Cayla Riva sets a 157mph land-speed record at '
        'Bonneville aboard a specially tuned Continental GT 650.',
  ),
  StoryEntry(
    id: '2019_kx',
    year: '2019',
    eraKey: 'e2011',
    description:
        'The 838cc KX Concept V-twin, inspired by 1930s KX models, is '
        'unveiled at EICMA as a showcase for the UK Technology Centre\'s '
        'design work.',
  ),
  StoryEntry(
    id: '2019_karakoram',
    year: '2019',
    eraKey: 'e2011',
    description:
        'A team of Army and Royal Enfield riders becomes the first to '
        'summit the 5,540m Karakoram Pass by motorcycle; the Bullet Trials '
        'Works Replica launches in tribute to 1950s trials rider Johnny '
        'Brittain.',
  ),
  StoryEntry(
    id: '2020_uce',
    year: '2020',
    eraKey: 'e2011',
    description:
        'Production of the long-running 500cc UCE engine ends, closed out '
        'by a limited Classic 500 Tribute Black.',
  ),
  StoryEntry(
    id: '2020_meteor',
    year: '2020',
    eraKey: 'e2011',
    description:
        'The Meteor 350 launches as the first model on Royal Enfield\'s '
        'new J-platform 350cc engine — a joint effort between the Chennai '
        'and UK teams — and wins Indian Motorcycle of the Year.',
  ),
  StoryEntry(
    id: '2021',
    year: '2021',
    eraKey: 'e2011',
    description:
        'Royal Enfield marks 120 years with "Project Origin," a faithful '
        'working replica of the original 1901 motorcycle, built with help '
        'from vintage-motorcycle specialists.',
  ),
  StoryEntry(
    id: '2022',
    year: '2022',
    eraKey: 'e2011',
    description:
        'The Hunter 350 launches in Bangkok, built with a shorter '
        'wheelbase and lighter weight for easy manoeuvring through city '
        'streets.',
  ),
  StoryEntry(
    id: '2023',
    year: '2023',
    eraKey: 'e2011',
    description:
        'The Super Meteor 650 launches as a full-size cruiser aimed at '
        'open-road and city riding alike, quickly becoming a favourite '
        'among owners.',
  ),
  StoryEntry(
    id: '2024',
    year: '2024',
    eraKey: 'e2011',
    description:
        'The Guerrilla 450 launches in Barcelona, targeting the '
        'performance-roadster segment with the Sherpa 450 platform '
        'underneath.',
  ),
];
