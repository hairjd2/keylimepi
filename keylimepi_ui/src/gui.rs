// use iced::widget::{pick_list, text};
// use iced::Element;
// use iced::color;

// #[derive(Default)]
// struct State {
//    favorite: Option<Fruit>,
// }

// #[derive(Debug, Clone, Copy, PartialEq, Eq)]
// enum Fruit {
//     Apple,
//     Orange,
//     Strawberry,
//     Tomato,
// }

// #[derive(Debug, Clone)]
// enum Message {
//     FruitSelected(Fruit),
// }

// fn view(state: &State) -> Element<'_, Message> {
//     let fruits = [
//         Fruit::Apple,
//         Fruit::Orange,
//         Fruit::Strawberry,
//         Fruit::Tomato,
//     ];
    
//     // text("Domains:")
//     //     .size(20)
//     //     .color(color!(0x0000ff))
//     //     .into();

//     pick_list(
//         fruits,
//         state.favorite,
//         Message::FruitSelected,
//     )
//     .placeholder("Select your favorite fruit...")
//     .into()
// }

// fn update(state: &mut State, message: Message) {
//     match message {
//         Message::FruitSelected(fruit) => {
//             state.favorite = Some(fruit);
//         }
//     }
// }

// impl std::fmt::Display for Fruit {
//     fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
//         f.write_str(match self {
//             Self::Apple => "Apple",
//             Self::Orange => "Orange",
//             Self::Strawberry => "Strawberry",
//             Self::Tomato => "Tomato",
//         })
//     }
// }

// pub fn main_gui() {
//     iced::run(update, view);
// }
