import datetime
from typing import List
from dataclasses import dataclass
import math


@dataclass
class Attraction:
    """관광지 정보"""
    id: int
    name: str
    region: str
    categories: List[str]
    travel_companions: List[str]
    lat: float
    lon: float
    avg_duration: float
    opening_time: int = 9
    closing_time: int = 22
    priority_score: float = 0


@dataclass
class DailyItinerary:
    """일일 일정"""
    date: datetime.date
    attractions: List[Attraction]
    total_distance: float


class DatabaseConnector:
    """데이터베이스 연결 및 데이터 조회"""
    
    def __init__(self, db_connection):
        """
        사용 예시:
        import pymysql
        conn = pymysql.connect(host='localhost', user='root', password='...', db='travel_db')
        db = DatabaseConnector(conn)
        """
        self.conn = db_connection
    
    def fetch_attractions(self, region: str, interests: List[str], companion: str):
        """
        DB에서 조건에 맞는 관광지 조회
        
        Parameters:
        - region: 지역 (서울, 부산, 제주, 인천, 강릉, 전주, 기타)
        - interests: 관심사 리스트 (K-pop, Food, History, Cafe, Shopping)
        - companion: 동행자 (friends, family, solo)
        
        Returns:
        - List[Attraction]: 조건에 맞는 관광지 리스트
        """
        cursor = self.conn.cursor()
        
        # 카테고리 조건 생성
        category_placeholders = ','.join(['%s'] * len(interests))
        
        query = f"""
        SELECT DISTINCT
            a.id, a.name, a.region, a.latitude, a.longitude, 
            a.avg_duration, a.opening_time, a.closing_time
        FROM attractions a
        INNER JOIN attraction_companions ac ON a.id = ac.attraction_id
        INNER JOIN attraction_categories cat ON a.id = cat.attraction_id
        WHERE a.region = %s
        AND ac.companion_type = %s
        AND cat.category IN ({category_placeholders})
        ORDER BY a.popularity_score DESC
        LIMIT 100
        """
        
        params = [region, companion] + interests
        cursor.execute(query, params)
        results = cursor.fetchall()
        
        attractions = []
        for row in results:
            # 각 관광지의 모든 카테고리 가져오기
            cursor.execute(
                "SELECT category FROM attraction_categories WHERE attraction_id = %s", 
                (row['id'],)
            )
            categories = [cat['category'] for cat in cursor.fetchall()]
            
            # 각 관광지의 모든 동행자 타입 가져오기
            cursor.execute(
                "SELECT companion_type FROM attraction_companions WHERE attraction_id = %s", 
                (row['id'],)
            )
            companions = [comp['companion_type'] for comp in cursor.fetchall()]
            
            attractions.append(Attraction(
                id=row['id'],
                name=row['name'],
                region=row['region'],
                categories=categories,
                travel_companions=companions,
                lat=float(row['latitude']),
                lon=float(row['longitude']),
                avg_duration=float(row['avg_duration']),
                opening_time=int(row['opening_time']),
                closing_time=int(row['closing_time'])
            ))
        
        return attractions


class TravelRecommendationSystem:
    """여행 일정 추천 시스템"""
    
    def __init__(self, db_connector):
        """
        Parameters:
        - db_connector: DatabaseConnector 인스턴스
        """
        self.db = db_connector
    
    def calculate_distance(self, lat1: float, lon1: float, lat2: float, lon2: float):
        """두 지점 간 거리 계산 (Haversine formula, km 단위)"""
        R = 6371
        
        dlat = math.radians(lat2 - lat1)
        dlon = math.radians(lon2 - lon1)
        a = (math.sin(dlat / 2) ** 2 + 
             math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * 
             math.sin(dlon / 2) ** 2)
        c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
        
        return R * c
    
    def calculate_match_score(self, attraction: Attraction, interests: List[str]):
        """관광지와 사용자 관심사 매칭 점수 계산"""
        matched = sum(1 for interest in interests if interest in attraction.categories)
        category_diversity = len(set(attraction.categories) & set(interests))
        return matched * 2 + category_diversity
    
    def optimize_daily_route(self, attractions: List[Attraction], 
                            start_time: int = 9, 
                            max_hours: int = 12,
                            target_count: int = 4):
        """
        하루 일정 최적화 - 효율적인 동선 고려
        
        Parameters:
        - attractions: 선택 가능한 관광지 리스트
        - start_time: 활동 시작 시간 (기본 9시)
        - max_hours: 최대 활동 시간 (기본 12시간)
        - target_count: 목표 방문 관광지 수 (기본 4곳)
        
        Returns:
        - (선택된 관광지 리스트, 총 이동거리)
        """
        if not attractions:
            return [], 0
        
        selected = []
        available = attractions.copy()
        total_distance = 0
        current_time = start_time
        
        # 첫 관광지는 매칭 점수가 가장 높은 것
        first = max(available, key=lambda a: a.priority_score)
        available.remove(first)
        selected.append(first)
        current_lat, current_lon = first.lat, first.lon
        current_time += first.avg_duration
        
        # 목표 개수만큼 관광지 선택
        while available and len(selected) < target_count and current_time < start_time + max_hours:
            # 현재 시간에 방문 가능한 곳
            valid = [
                a for a in available 
                if current_time >= a.opening_time and 
                   current_time + a.avg_duration <= min(a.closing_time, start_time + max_hours)
            ]
            
            if not valid:
                break
            
            # 거리와 매칭점수 모두 고려
            def selection_score(a):
                dist = self.calculate_distance(current_lat, current_lon, a.lat, a.lon)
                return a.priority_score * 10 - dist
            
            next_attraction = max(valid, key=selection_score)
            
            distance = self.calculate_distance(current_lat, current_lon, 
                                              next_attraction.lat, next_attraction.lon)
            travel_time = distance / 30  # 평균 속도 30km/h
            
            if current_time + travel_time + next_attraction.avg_duration > start_time + max_hours:
                break
            
            selected.append(next_attraction)
            available.remove(next_attraction)
            current_lat, current_lon = next_attraction.lat, next_attraction.lon
            current_time += travel_time + next_attraction.avg_duration
            total_distance += distance
        
        return selected, total_distance
    
    def generate_itinerary(self, region: str, start_date: datetime.date, 
                          end_date: datetime.date, companion: str, 
                          interests: List[str]):
        """
        사용자 맞춤형 여행 일정 생성
        
        Parameters:
        - region: 여행 지역 (서울, 부산, 제주, 인천, 강릉, 전주, 기타)
        - start_date: 여행 시작 날짜 (datetime.date)
        - end_date: 여행 종료 날짜 (datetime.date)
        - companion: 동행자 타입 (friends, family, solo)
        - interests: 관심사 리스트 (K-pop, Food, History, Cafe, Shopping)
        
        Returns:
        - List[DailyItinerary]: 날짜별 일정 리스트
        
        Example:
            itinerary = system.generate_itinerary(
                region="서울",
                start_date=datetime.date(2025, 12, 20),
                end_date=datetime.date(2025, 12, 22),
                companion="friends",
                interests=["K-pop", "Food", "Shopping"]
            )
        """
        
        # 1. DB에서 조건에 맞는 관광지 가져오기
        all_attractions = self.db.fetch_attractions(region, interests, companion)
        
        if not all_attractions:
            return []
        
        # 2. 매칭 점수 계산
        for attraction in all_attractions:
            attraction.priority_score = self.calculate_match_score(attraction, interests)
        
        # 3. 매칭 점수순 정렬
        all_attractions.sort(key=lambda a: a.priority_score, reverse=True)
        
        # 4. 여행 일수 계산
        num_days = (end_date - start_date).days + 1
        
        # 5. 하루당 방문할 관광지 수 계산
        total_attractions = len(all_attractions)
        attractions_per_day = max(3, min(5, total_attractions // num_days))
        
        if total_attractions < num_days * 3:
            attractions_per_day = max(2, total_attractions // num_days)
        
        # 6. 각 날짜별 일정 생성
        itinerary = []
        used_attractions = set()
        
        for day in range(num_days):
            current_date = start_date + datetime.timedelta(days=day)
            
            # 아직 사용하지 않은 관광지만 선택
            available = [a for a in all_attractions if a.id not in used_attractions]
            
            if not available:
                # 관광지가 부족하면 재방문
                available = all_attractions.copy()
                used_attractions.clear()
            
            # 하루 일정 최적화
            daily_route, distance = self.optimize_daily_route(
                available, 
                start_time=9, 
                max_hours=12,
                target_count=attractions_per_day
            )
            
            if daily_route:
                for attr in daily_route:
                    used_attractions.add(attr.id)
                
                itinerary.append(DailyItinerary(
                    date=current_date,
                    attractions=daily_route,
                    total_distance=round(distance, 2)
                ))
        
        return itinerary


# ==================== 사용 예시 ====================
"""
# 1. DB 연결
import pymysql

conn = pymysql.connect(
    host='localhost',
    user='root',
    password='your_password',
    db='travel_db',
    charset='utf8mb4',
    cursorclass=pymysql.cursors.DictCursor
)

# 2. 시스템 초기화
db = DatabaseConnector(conn)
system = TravelRecommendationSystem(db)

# 3. 일정 생성
itinerary = system.generate_itinerary(
    region="서울",
    start_date=datetime.date(2025, 12, 20),
    end_date=datetime.date(2025, 12, 22),
    companion="friends",
    interests=["K-pop", "Food", "Shopping"]
)

# 4. 결과 사용
for day_plan in itinerary:
    print(f"날짜: {day_plan.date}")
    print(f"이동거리: {day_plan.total_distance}km")
    for attraction in day_plan.attractions:
        print(f"  - {attraction.name}")

# 5. DB 연결 종료
conn.close()
"""