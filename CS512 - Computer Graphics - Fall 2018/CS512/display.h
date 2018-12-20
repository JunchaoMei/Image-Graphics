#pragma once

#include "obj_loader.h"

void drawString(const char* str);
void selectFont(int size, int charset, const char* face);
void displayMain();
void switchHandedness();
void swithCulling();
void drawPrimitives(IndexedModel model, GLenum primitive, int repre);
void setGlobalAmbientLight();
void setPointLight();
void displaySub1();
void printGLfloatArray(GLfloat arr[]);
void readShaderFile(const GLchar* shaderPath, std::string& shaderCode);
void setShaders();
void initBufferObject(void);
void displaySub2();
void updateShader();
void reshapeMain(int w, int h);
void loadNewFile(std::string newObjFile);
void printMaterialLightConstInfo();
void printColorLightInfo();
void colorMenu(int value);
//void primitiveMenu(int value);
void camTransMenu(int value);
void camRotateMenu(int value);
void camClipMenu(int value);
void cameraMenu(int value);
void handednessMenu(int value);
void faceCullingMenu(int value);
void globalAmbRGBMenu(int value);
void globalAmbAlphaMenu(int value);
void pointlightAmbRGBMenu(int value);
void pointLightAmbAlphaMenu(int value);
void pointlightDiffRGBMenu(int value);
void pointLightDiffAlphaMenu(int value);
void pointlightSpecRGBMenu(int value);
void pointLightSpecAlphaMenu(int value);
void pointLightMenu(int value);
void lightMenu(int value);
void shadingMenu(int value);
void emptyMenu(int value);
void mainMenu(int value);
void createMenu();