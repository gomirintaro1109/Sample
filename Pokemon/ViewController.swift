//
//  ViewController.swift
//  Pokemon
//
//  Created by gomiRintaro on 2023/06/08.
//
import UIKit
import SDWebImage

//ポケモンの情報を表す構造体
struct Pokemon: Codable {
    let id: Int
    let name: String
    let sprites: Sprites
}

struct Sprites: Codable {
    let front_default: String
}

// カスタムのUICollectionViewCellサブクラス
final class CustomCell: UICollectionViewCell {
    let avatarImageView = UIImageView()
    let idLabel = UILabel()
    let nameLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension CustomCell {
    func setupViews() {
        // サブビューの設定とレイアウトの構成
        // 赤色の上半分
        let redView = UIView()
        redView.backgroundColor = .red
        contentView.addSubview(redView)
        redView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            redView.topAnchor.constraint(equalTo: contentView.topAnchor),
            redView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            redView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            redView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.5)
        ])

        // 白色の下半分
        let whiteView = UIView()
        whiteView.backgroundColor = .white
        contentView.addSubview(whiteView)
        whiteView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            whiteView.topAnchor.constraint(equalTo: redView.bottomAnchor),
            whiteView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            whiteView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            whiteView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        // 画像ビューの設定
        avatarImageView.contentMode = .scaleAspectFit
        contentView.addSubview(avatarImageView)
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            avatarImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            avatarImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.8),
            avatarImageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.4)
        ])

        // IDラベルの設定
        idLabel.textAlignment = .center
        contentView.addSubview(idLabel)
        idLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            idLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8.0),
            idLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8.0),
            idLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8.0),
            idLabel.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.2)
        ])

        // 名前ラベルの設定
        nameLabel.textAlignment = .center
        contentView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8.0),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8.0),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8.0),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8.0)
        ])

        contentView.layer.cornerRadius = frame.height / 2
        contentView.layer.borderWidth = 2.0
        contentView.layer.borderColor = UIColor.black.cgColor
        contentView.clipsToBounds = true
    }
}

// コレクションビューを表示するビューコントローラー
final class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var pokemonListCollectionView: UICollectionView!
    var pokemonList = [Pokemon]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // デリゲートを自身に設定
        pokemonListCollectionView.delegate = self
        
        // コレクションビューレイアウトを設定
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 170, height: 170)
        layout.minimumLineSpacing = 5.0
        layout.minimumInteritemSpacing = 5.0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)
        pokemonListCollectionView.collectionViewLayout = layout
        
        // カスタムセルクラスを登録
        pokemonListCollectionView.register(CustomCell.self, forCellWithReuseIdentifier: "Cell")
        // IDが1から151までのポケモンデータを取得
        for id in 1...151 {
            fetchPokemon(id: id)
        }
    }
    //APIからポケモンのデータの取得
    func fetchPokemon(id: Int) {
        let url = URL(string: "https://pokeapi.co/api/v2/pokemon/\(id)/")!

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
            } else if let data = data {
                do {
                    let pokemon = try JSONDecoder().decode(Pokemon.self, from: data)
                    self.pokemonList.append(pokemon)
                    DispatchQueue.main.async {
                        self.pokemonListCollectionView.reloadData()
                        //IDの順番にソート
                        self.pokemonList.sort {$0.id < $1.id}
                        DispatchQueue.main.async {
                            self.pokemonListCollectionView.reloadData()
                        }
                    }
                } catch {
                    print("Decoding Error: \(error)")
                }
            }
        }
        task.resume()
    }
    // UICollectionViewDataSourceプロトコルのメソッド - セクション内のアイテム数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 151
    }
    // UICollectionViewDataSourceプロトコルのメソッド - アイテムセルの構築
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CustomCell

        if indexPath.row < pokemonList.count {
            let pokemon = pokemonList[indexPath.row]

            cell.idLabel.text = String(pokemon.id)
            cell.nameLabel.text = pokemon.name

            if let imageUrl = URL(string: pokemon.sprites.front_default) {
                cell.avatarImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholder.png"))
            }
        }
        return cell
    }
    // UICollectionViewDelegateプロトコルのメソッド - セルの選択時の処理
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row < pokemonList.count {
            let pokemon = pokemonList[indexPath.row]

            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let detailVC = storyboard.instantiateViewController(withIdentifier: "PokemonDetailViewController") as? PokemonDetailViewController {
                detailVC.pokemon = pokemon
                print("Attempting to navigate to detail view...")
                navigationController?.pushViewController(detailVC, animated: true)
            }
        }
    }
}
