package com.example.booktrack


import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.material3.TextFieldDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment.Companion.CenterHorizontally
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.foundation.layout.Box as Box
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.material3.Text
import androidx.compose.ui.text.font.FontWeight


class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            MainScreen()
        }
    }
}

@Composable
fun MainScreen(){
    Column() {
        SearchSlaid()
    }
}

@Preview(showBackground = true)
@Composable
fun MainScreenPreview() {
    MainScreen()
}
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SearchSlaid(){
    val message = remember{mutableStateOf("")
    }
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .fillMaxHeight()
            .background(Color(0xFF5775CD))
            .padding(top = 23.dp)
    ){
        OutlinedTextField(

            message.value,
            {message.value = it},
            textStyle = TextStyle(fontSize =  30.sp),
            placeholder = { Text("Что вы хотите почитать?",
                fontSize = 14.sp,
                color = Color.White.copy(alpha = 0.6f))},
            colors = TextFieldDefaults.outlinedTextFieldColors(
                containerColor =(Color(0xFF3A4E88)),
                focusedBorderColor= Color(0xffcccccc), // цвет при получении фокуса
                unfocusedBorderColor = Color(0xff3A4E88)  // цвет при отсутствии фокуса
            ),
            modifier = Modifier
                .width(329.dp)
                .height(50.dp)
                .align(CenterHorizontally)
                .clip(RoundedCornerShape(35.dp)),

        )
        InfinitePager()
        TabScreen()
    }

}

@OptIn(ExperimentalMaterial3Api::class, ExperimentalFoundationApi::class)
@Composable
fun InfinitePager() {
    val blockWidth = 320.dp
    val blockHeight = 150.dp
    val visibleOffset = 23.dp

    // Укажите количество страниц
    val pageCount = 6
    val pagerState = rememberPagerState(pageCount = { pageCount }, initialPage = 1)

    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(blockHeight + visibleOffset)
            .padding(top = visibleOffset)
    ) {
        HorizontalPager(
            state = pagerState,
            modifier = Modifier.fillMaxSize()
        ) { page ->
            Box(
                modifier = Modifier
                    .size(blockWidth, blockHeight) //
                    .background(color = Color(0xFFFD521B),
                        shape = RoundedCornerShape(12.dp)
                    )
            )
        }
    }
}


@Composable
fun TabScreen() {
    var tabIndex by remember { mutableStateOf(0) }

    val tabs = listOf("Рекомендации", "Популярные", "Жанры", "Скоро в продаже")

    Column(modifier = Modifier.fillMaxWidth()) {
        TabRow(selectedTabIndex = tabIndex,
        containerColor = Color(0xFF5775CD),
        modifier=Modifier
            .padding(10.dp)
            ) {
            tabs.forEachIndexed { index, title ->
                Tab(text = { Text(title) },
                    selected = tabIndex == index,
                    onClick = { tabIndex = index }

                )
            }
        }
        when (tabIndex) {
            0 -> HomeScreen()
            1 ->Box(
                modifier = Modifier
                    .size(320.dp, 400.dp) //
                    .background(color = Color(0xFFFD523B),
                        shape = RoundedCornerShape(12.dp)
                    )
            )
            2 ->  Box(
                modifier = Modifier
                    .size(320.dp, 400.dp) //
                    .background(color = Color(0xFFFD121B),
                        shape = RoundedCornerShape(12.dp)
                    )
            )
            3 ->  Box(
                modifier = Modifier
                    .size(320.dp, 400.dp) //
                    .background(color = Color(0xFFFD121B),
                        shape = RoundedCornerShape(12.dp)
                    )
            )
        }
    }
}
@Composable
fun HomeScreen(){
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .fillMaxHeight()
            .background(color = Color(0xFFFFFFFF),
                shape = RoundedCornerShape(topStart = 20.dp, topEnd = 20.dp)
        )
    ){
        Column(
            modifier = Modifier
                .padding(top=32.dp, start = 23.dp)
        ) {
            Row {
                Text("Новинки",
                    fontSize=16.sp,
                    fontWeight = FontWeight(700)
                    )
            }
        }
    }
}



