import 'package:flutter/material.dart';
import '../utils/app_colors.dart'; // Certifique-se de ter a cor roxa definida aqui
import '../utils/app_text_styles.dart'; // Certifique-se de ter estilos de texto configurados aqui

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Cor de fundo branca
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.purpledarkOne), // Ícone roxo para voltar
          onPressed: () {
            Navigator.of(context).pop(); // Voltar à tela anterior
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título "Sobre"
                  Center(
                    child: Text(
                      'Sobre',
                      style: AppTextStyles.bigText.copyWith(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: AppColors.purpledarkOne, // Texto em roxo
                      ),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  // Texto informativo
                  Text(
                    'O Despesa Digital foi desenvolvido com o objetivo de realizar o controle financeiro pessoal '
                        'de maneira eficiente e prática.',
                    style: AppTextStyles.smallText.apply(
                      color: Colors.black87, // Texto em preto suave
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'O projeto foi desenvolvido durante o 1º e 2º Semestre de 2024 pelos alunos da Fatec Itapira no Curso de DSM.',
                    style: AppTextStyles.smallText.apply(
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  SizedBox(height: 16.0),
                  // Título para os desenvolvedores
                  Text(
                    'Desenvolvido por:',
                    style: AppTextStyles.smallText.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  // Lista de desenvolvedores
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Alinha os textos à esquerda
                    children: [
                      Text(
                        'Davi Aquila Siqueira da Silva',
                        style: AppTextStyles.smallText.apply(color: Colors.black87),
                      ),
                      Text(
                        'Leonardo Rodrigues Dezoti Ferraz',
                        style: AppTextStyles.smallText.apply(color: Colors.black87),
                      ),
                      Text(
                        'João Vitor Moreira Mariano da Silva',
                        style: AppTextStyles.smallText.apply(color: Colors.black87),
                      ),
                      Text(
                        'Lucas Augusto Borges Rogatto',
                        style: AppTextStyles.smallText.apply(color: Colors.black87),
                      ),
                      Text(
                        'Pedro Henrique Pires de Godoy',
                        style: AppTextStyles.smallText.apply(color: Colors.black87),
                      ),
                      Text(
                        'Vitor Gabriel Montini Melo',
                        style: AppTextStyles.smallText.apply(color: Colors.black87),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Agradecemos imensamente por utilizar nosso aplicativo.',
                    style: AppTextStyles.smallText.apply(
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),
          ),
          // Logo fixada na parte inferior
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Image.asset(
              'assets/images/logo1.png', // Caminho da logo
              width: 200,
              height: 200,
            ),
          ),
        ],
      ),
    );
  }
}
