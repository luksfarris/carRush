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
######No qual aprendemos a criar cameras, posicionar elementos, criar materiais e adicionar objetos à cena.
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

###Capítulo 2: A jornada do herói.
######No qual aprendemos criar ou importar objetos tridimensionais, animá-los e a interagir com o usuário.

Vamos criar um tímido cenário? Faremos uma faixa na nossa rodovia! Adicione este método e chame-o no `ViewDidLoad`:
```Swift
func createScenario() {
  for i in 20...70 {
    let laneMaterial = SCNMaterial()
    if i%5<2 { // se a divisao de i por 5 for igual a 0 ou 1
      laneMaterial.diffuse.contents = UIColor.clearColor()
    } else { // se a divisao de i por 5 for 2,3 ou 4
      laneMaterial.diffuse.contents = UIColor.blackColor()
    }
    let laneGeometry = SCNBox(width: 0.2, height: 0.1, length: 1, chamferRadius:0)
    laneGeometry.materials = [laneMaterial]
    let lane = SCNNode(geometry: laneGeometry)
    lane.position = SCNVector3(x: 0, y: 0, z: -Float(i))
    scene.rootNode.addChildNode(lane)
    let moveDown = SCNAction.moveByX(0, y:0 , z: 5, duration: 0.3)
    let moveUp = SCNAction.moveByX(0, y: 0, z: -5, duration: 0)
    let moveLoop = SCNAction.repeatActionForever(SCNAction.sequence([moveDown, moveUp]))
    lane.runAction(moveLoop)
  }
}
```
Ok, tem muita coisa acontecendo aqui, vamos por partes. Estamos dentro de um *loop*, no qual `i` vai assumir todos os valores entre `20` e `70`. Em cada iteração, colocamos um pequeno tijolinho, `preto` ou `transparente`, dependendo de `i`. Note que isso vai colocar tres tijolinhos pretos, e dois transparentes.
Em seguida, adicionamos uma animação ao conjunto. Todos os tijolinhos estão sujeitos a duas animações: `moveUp` e `moveDown`. A animação `moveLoop` combina as duas (usando o método `sequence`), e as repete para sempre (usando `repeatActionForever`). Por fim, `runAction`, que pode ser chamado a qualquer `SCNNode`, aplica a animação em cada um de nossos tijolinhos. Como cada faixa tem 3 tijolinhos pretos + 2 transparentes, nós andamos `5` pra baixo em `0.3` segundos, e instanteneamente subimos `5` pra dar a impressão de que é um movimento contínuo. Tente remover `moveUp` como experimento. Eis o resultado até agora:
![](https://github.com/luksfarris/carRush/blob/master/img/gif1.gif "Faixa!")

Vamos adicionar nosso personagem principal?
