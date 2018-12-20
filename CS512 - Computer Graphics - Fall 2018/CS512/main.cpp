#include <GL/glew.h>
#include <GL/freeglut.h>
#include <iostream>
#include <windows.h>
#include "display.h"
#include "mesh.h"
#include "camera.h"
//#include "transform.h"

#define WIDTH 500
#define HEIGHT 500

using namespace std;

GLenum primitive_main = GL_TRIANGLES;
int modelRep = 3;
Mesh* mesh_pt = NULL;
float Red = 1.0;
float Green = 1.0;
float Blue = 1.0;
float Alpha = 1.0;
Camera* camera_pt = NULL;
float fov_main = 60.0f;
float aspect_main = (float)WIDTH / (float)HEIGHT;
int mainWindow, subWin1, subWin2;

int main(int argc, char** argv)
{
	string objFileName;
	cout << "The *.obj file you want to load:  ";
	cin >> objFileName;
	cout << "Loading " << objFileName << " ...." << endl;

	Mesh mesh("./res/" + objFileName);
	mesh_pt = &mesh;

	//Camera cam(1.0f, 10.0f, glm::vec3(0.1, 0.2, 5), glm::vec3(0.3, 0.4, 0.5));
	Camera cam(mesh.zNear_opt, mesh.zFar_opt, mesh.eye_opt, mesh.lookat_opt);
	camera_pt = &cam;
	printMaterialLightConstInfo();

	glutInit(&argc, argv);
	glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB | GLUT_DEPTH);
	glutInitWindowSize(WIDTH*2+60, HEIGHT+70);
	glutInitContextFlags(GLUT_COMPATIBILITY_PROFILE);
	
	// 主窗口
	mainWindow = glutCreateWindow("Junchao Mei - CS512 - HW3");
	glClearColor(0.15f, 0.15f, 0.15f, 1.0f);
	glutDisplayFunc(displayMain);
	glutReshapeFunc(reshapeMain);
	createMenu();

	//Fixed Pipeline 子窗口
	subWin1 = glutCreateSubWindow(mainWindow, 20, 50, WIDTH, HEIGHT);
	glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
	glutDisplayFunc(displaySub1);

	//Shader 子窗口
	subWin2 = glutCreateSubWindow(mainWindow, WIDTH+40, 50, WIDTH, HEIGHT);
	glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
	glewInit();
	initBufferObject();
	setShaders();
	glutDisplayFunc(displaySub2);
	
	glutIdleFunc(displayMain);
	glutMainLoop();
	return 0;
}