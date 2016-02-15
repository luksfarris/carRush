##SceneKit Overview

######Autor: Lucas Farris (@luksfarris)

Este artigo pertence à série de artigos equinociOS, e aqui irei tratar do framework [SceneKit](https://developer.apple.com/library/ios/documentation/SceneKit/Reference/SceneKit_Framework/), que é uma bibiliteca para desenvolvimento de gráficos 3d de alta performance. O código será escrito em `Swift`, e um exemplo completo do projeto pode ser encontrado [neste repositório](https://github.com/luksfarris/carRush).

---

Durante este texto iremos recriar juntos uma versão minimalista do fantástico jogo [2 cars] (https://itunes.apple.com/en/app/2-cars/id936839198?mt=8), mas em um ambiente tridimensional. Com isso aprenderemos sobre:
- Física e colisões
- Texturas e modelos 3d
- Sistemas de partícula
- Animações e interação com o usuário

Para acompanhar não é necessário conhecimento prévio de Swift, apenas de programação básica, e algumas noções de geometria.

###Prólogo: Criando o projeto
Comece tendo certeza que seu XCode está atualizado, pelo menos na versão `Version 7.2`. Crie um novo projeto, do tipo `Game`, escolha `Swift` para a linguagem, `SceneKit` como tecnologia, e `Universal` nos dispositivos. Salve onde preferir.

![](https://github.com/luksfarris/carRush/blob/master/img/img1.png "Configuracão do projeto")

No projeto criado, voce poderá encontrar o arquivo `GameViewController.swift`. Abra ele e vamos comecar!

###Capítulo 1: Luzes, Camera e Ação!
######A parte em que aprendemos a criar cameras, posicionar elementos, criar materiais e adicionar objetos à cena.
Apague tudo na classe GameView Controller, e deixe apenas:

```Swift
import UIKit
import QuartzCore
import SceneKit
class GameViewController: UIViewController {
}
```
Em seguida, adicione variáveis pra camera, pro chão e pra nossa cena:
```Swift
var camera:SCNNode!
var ground:SCNNode!
var scene:SCNScene!
```
Adicione uma função para criar a cena:
```Swift
func createScene () {
  scene = SCNScene()
  let scnView = self.view as! SCNView
  scnView.scene = scene
  scnView.allowsCameraControl = true
  scnView.showsStatistics = true
  scnView.playing = true
  scnView.autoenablesDefaultLighting = true
}
```
Adicione uma função responsável por criar a camera. Note que `.position` é a propriedade que define a posição tridimensional da camera, e `eulerAngles` (medidos em radianos) definem a orientação (pra onde a camera aponta). Os fotógrafos amadores poderão se divertir com os [demais parametros disponíveis para cameras](http://flexmonkey.blogspot.com/2015/05/depth-of-field-in-scenekit.html).
```Swift
func createCamera () {
  camera = SCNNode()
  camera.camera = SCNCamera()
  camera.position = SCNVector3(x: 0, y: 25, z: -18)
  camera.eulerAngles = SCNVector3(x: -1, y: 0, z: 0)
  camera.camera?.aperture = 1/2
  scene.rootNode.addChildNode(camera)
}
```
Adicione uma função responsável por criar o chão. `SCNFloor` cria um plano infinito fixado inicialmente na origem. Note que vamos dar uma tonalidade cinza pra ele usando um `SCNMaterial`.
```Swift
func createGround () {
  let groundGeometry = SCNFloor()
  groundGeometry.reflectivity = 0.5
  let groundMaterial = SCNMaterial()
  groundMaterial.diffuse.contents = UIColor.darkGrayColor()
  groundGeometry.materials = [groundMaterial]
  ground = SCNNode(geometry: groundGeometry)
  scene.rootNode.addChildNode(ground)
}
```
E junte tudo no método `ViewDidLoad()`:
```Swift
override func viewDidLoad() {
  super.viewDidLoad()
  createScene()
  createCamera()
  createGround()
}
```

Compile e rode e veja nosso cenário inicial. Use gestos para circular pelo terreno tridimensional.
![](https://github.com/luksfarris/carRush/blob/master/img/img2.png "Cenário inicial")
