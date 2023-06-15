//
//  PokemonDetailViewController.swift
//  Pokemon
//
//  Created by gomiRintaro on 2023/06/13.
//

import UIKit

final class PokemonDetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!

    var pokemon: Pokemon?

    override func viewDidLoad() {
        super.viewDidLoad()
        // ビューがロードされた際に実行される処理
        setUpView()
    }
}

private extension PokemonDetailViewController {

    func setUpView() {
        if let pokemon = pokemon {
            idLabel.text = String(pokemon.id)
            nameLabel.text = pokemon.name

            if let imageUrl = URL(string: pokemon.sprites.front_default){
                // SDWebImageを使用してポケモンの画像を表示
                imageView.sd_setImage(with: imageUrl,placeholderImage: UIImage(named:"placehoder.png"))
            }
        }
    }
}
