//
//  LevelGenerator.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 07/05/26.
//

import CoreGraphics
import GameplayKit

struct GeneratedPlatform {
    let position: CGPoint
    let textureName: String
    let type: PlatformType
}

enum PlatformType {
    case backbone
    case start
    case decoration
}

enum TrapPlacement {
    case platform
    case air
}

struct GeneratedTrap {
    let position: CGPoint
    let type: TrapType
}

struct GeneratedLevel {
    let platforms: [GeneratedPlatform]
    let traps: [GeneratedTrap]
    let startPositions: [CGPoint]
}

class LevelGenerator {
    private struct PlatformCell {
        let column: Int
        let row: Int
        let offsetX: CGFloat
        let offsetY: CGFloat
    }
    
    private struct CellKey: Hashable {
        let column: Int
        let row: Int
    }
    
    private enum Zone {
        case left, center, right
    }
    
    private let config: LevelConfig
    private let randomSource: GKLinearCongruentialRandomSource
    
    private var occupiedCells = Set<CellKey>()
    private var platformsByRow: [Int: [PlatformCell]] = [:]
    
    private let safeMinColumn: Int = 0
    private var safeMaxColumn: Int {
        config.gridColumns - 1
    }
    
    private var gridCellWidth: CGFloat {
        config.mapWidth / CGFloat(config.gridColumns)
    }
    
    private var gridRowHeight: CGFloat {
        config.finishLineY / CGFloat(config.gridRows + 2)
    }
    
    init(config: LevelConfig, seed: UInt64) {
        self.config = config
        self.randomSource = GKLinearCongruentialRandomSource(seed: seed)
    }
    
    func generate() -> GeneratedLevel {
        occupiedCells.removeAll()
        platformsByRow.removeAll()
        
        var allCells: [PlatformCell] = []
        
        // Starting area
        let startCol = nextRandomInt(safeMinColumn...safeMaxColumn)
        let startCell = makeCell(column: startCol, row: 1, offsetRange: 15)
        placeCell(startCell, into: &allCells)
        let startCount = allCells.count
        
        // Backbone (from entry row + 1 to top)
        _ = generateBackbone(from: startCell, allCells: &allCells)
        let backboneCount = allCells.count
        
        // Decorations
        _ = generateDecorations(allCells: &allCells)
        
        // Traps
        let traps = generateTraps(allCells: allCells)
        
//        let platforms = allCells.map { createPlatform(from: $0) }
        
        let platforms = allCells.enumerated().map { index, cell -> GeneratedPlatform in
            let type: PlatformType
            if index < startCount {
                type = .start
            } else if index < backboneCount {
                type = .backbone
            } else {
                type = .decoration
            }
            return GeneratedPlatform(
                position: worldPosition(for: cell),
                textureName: "PlatformEarth",
                type: type
            )
        }
        
        let playerHalfHeight: CGFloat = 32 // 64x64
        let floorTopY = config.startY + config.floorSize.height / 2
        
        let startPositions = [
            CGPoint(
                x: config.mapWidth / 2,
                y: floorTopY + playerHalfHeight + 2
            )
        ]
        
        return GeneratedLevel(
            platforms: platforms,
            traps: traps,
            startPositions: startPositions
        )
    }
    
    // MARK: - Backbone Generation
    
    private func generateBackbone(from entry: PlatformCell, allCells: inout [PlatformCell]) -> [PlatformCell] {
        var cells: [PlatformCell] = []
        
        let maxRow = config.gridRows - 1
        var currentCol = entry.column
        var previousCell = entry
        var consecutiveSameColumn = 0
        
        // Momentum state
        var lastDirection = nextRandom(in: 0...1) < 0.5 ? -1 : 1
        var lastWasSameColumn = false
        
        // Zone state
        var currentZone = zone(for: currentCol)
        var stepsInZone = 0
        
        for row in (entry.row + 1)...maxRow {
            let direction = chooseBackboneDirection(
                currentColumn: currentCol,
                lastDirection: lastDirection,
                lastWasSameColumn: lastWasSameColumn,
                consecutiveSameColumn: consecutiveSameColumn,
                stepsInZone: stepsInZone,
                currentZone: currentZone
            )
            
            let targetCol = clamp(
                currentCol + direction,
                min: safeMinColumn,
                max: safeMaxColumn
            )
            
            let cell = makeCell(column: targetCol, row: row)
            
            if isReachable(from: previousCell, to: cell) && isCellFree(cell) && !wouldStack(column: targetCol, row: row) {
                cells.append(cell)
                placeCell(cell, into: &allCells)
                updateBackboneState(
                    from: currentCol,
                    to: targetCol,
                    lastDirection: &lastDirection,
                    lastWasSameColumn: &lastWasSameColumn,
                    consecutiveSameColumn: &consecutiveSameColumn,
                    stepsInZone: &stepsInZone,
                    currentZone: &currentZone
                )
                currentCol = targetCol
                previousCell = cell
                continue
            }
            
            // Fallback
            var placed = false
            for fallbackDir in [lastDirection, -lastDirection, 0] {
                let fallbackCol = clamp(
                    currentCol + fallbackDir,
                    min: safeMinColumn,
                    max: safeMaxColumn
                )
                let fallbackCell = makeCell(column: fallbackCol, row: row)
                
                if isReachable(from: previousCell, to: fallbackCell) && isCellFree(fallbackCell) && !wouldStack(column: fallbackCol, row: row) {
                    cells.append(fallbackCell)
                    placeCell(fallbackCell, into: &allCells)
                    updateBackboneState(
                        from: currentCol,
                        to: fallbackCol,
                        lastDirection: &lastDirection,
                        lastWasSameColumn: &lastWasSameColumn,
                        consecutiveSameColumn: &consecutiveSameColumn,
                        stepsInZone: &stepsInZone,
                        currentZone: &currentZone
                    )
                    currentCol = fallbackCol
                    previousCell = fallbackCell
                    placed = true
                    break
                }
            }
            
            if !placed {
                let fallbackCell = PlatformCell(
                    column: currentCol,
                    row: row,
                    offsetX: 0,
                    offsetY: 0
                )
                cells.append(fallbackCell)
                placeCell(fallbackCell, into: &allCells)
                lastWasSameColumn = true
                consecutiveSameColumn += 1
                stepsInZone += 1
                previousCell = fallbackCell
            }
        }
        
        return cells
    }
    
    private func wouldStack(column: Int, row: Int) -> Bool {
        // Check row above
        if let aboveCells = platformsByRow[row - 1] {
            if aboveCells.contains(where: { $0.column == column }) {
                return true
            }
        }
        // Check row below
        if let belowCells = platformsByRow[row + 1] {
            if belowCells.contains(where: { $0.column == column }) {
                return true
            }
        }
        return false
    }
    
    private func chooseBackboneDirection(
        currentColumn: Int,
        lastDirection: Int,
        lastWasSameColumn: Bool,
        consecutiveSameColumn: Int,
        stepsInZone: Int,
        currentZone: Zone
    ) -> Int {
        // Choose direction when near map edge
        if currentColumn <= safeMinColumn { return 1 }
        if currentColumn >= safeMaxColumn { return -1 }
        
        // Zone forcing
        if stepsInZone >= 4 {
            switch currentZone {
            case .left: return 1
            case .right: return -1
            case .center: return lastDirection
            }
        }
        
        // Force direction change
        if lastWasSameColumn || consecutiveSameColumn >= 2 {
            return nextRandom(in: 0...1) < 0.5 ? -1 : 1
        }
        
        // Momentum weights: 55% continue, 40% reverse, 5% hold
        let roll = nextRandom(in: 0...100)
        if roll < 55 { return lastDirection }
        else if roll < 95 { return -lastDirection }
        else { return 0 }
    }
    
    private func updateBackboneState(
        from oldCol: Int,
        to newCol: Int,
        lastDirection: inout Int,
        lastWasSameColumn: inout Bool,
        consecutiveSameColumn: inout Int,
        stepsInZone: inout Int,
        currentZone: inout Zone
    ) {
        let move = newCol - oldCol
        lastWasSameColumn = (move == 0)
        
        if move == 0 {
            consecutiveSameColumn += 1
        } else {
            consecutiveSameColumn = 0
            lastDirection = move > 0 ? 1 : -1
        }
        
        let newZone = zone(for: newCol)
        if newZone == currentZone {
            stepsInZone += 1
        } else {
            stepsInZone = 0
            currentZone = newZone
        }
    }
    
    // MARK: - Decoration
    
    private func generateDecorations(allCells: inout [PlatformCell]) -> [PlatformCell] {
        var decorations: [PlatformCell] = []
        let maxRow = config.gridRows - 1
        
        // Store all column in that row
        var columnsOnRow: [Int: Set<Int>] = [:]
        for (row, cells) in platformsByRow {
            columnsOnRow[row] = Set(cells.map { $0.column })
        }
        
        var backboneColByRow: [Int: Int] = [:]
        for (row, cells) in platformsByRow {
            if let first = cells.first {
                backboneColByRow[row] = first.column
            }
        }
        
        for row in 1...maxRow {
            guard platformCountOnRow(row) < config.maxPlatformsPerRow else { continue }
            
            guard nextRandom(in: 0...100) < config.decorationProbability else { continue }
            
            let sourceCells = platformsByRow[row - 1] ?? []
            guard !sourceCells.isEmpty else { continue }
            
            let sameRowCols = columnsOnRow[row] ?? []
            let aboveRowCols = columnsOnRow[row + 1] ?? []
            let belowRowCols = columnsOnRow[row - 1] ?? []
            
            for _ in 0..<20 {
                let col = nextRandomInt(safeMinColumn...safeMaxColumn)
                
                // Must be at least 2 columns from any platform on same row
                if sameRowCols.contains(where: { abs(col - $0 ) < 2 }){
                    continue
                }
                
                // Must not stack directly above or below a backbone platform
                if aboveRowCols.contains(col) || belowRowCols.contains(col) {
                    continue
                }
                
                let cell = makeCell(column: col, row: row)
                guard isCellFree(cell) else { continue }
                
                // Must be reachable from below
                let reachable = sourceCells.contains { isReachable(from: $0, to: cell) }
                guard reachable else { continue }
                
                decorations.append(cell)
                placeCell(cell, into: &allCells)
                
                // Create chain (distraction)
                if nextRandom(in: 0...100) < config.chainProbability {
                    let chainLength = nextRandomInt(1...3)
                    var chainPrevious = cell
                    
                    for _ in 0..<chainLength {
                        let chainRow = chainPrevious.row + 1
                        guard chainRow < maxRow else { break }
                        guard platformCountOnRow(chainRow) < config.maxPlatformsPerRow else { break }
                        
                        // Move away from backbone
                        let backboneCol = backboneColByRow[chainRow]
                        let awayDirection: Int
                        if let backbone = backboneCol {
                            awayDirection = chainPrevious.column > backbone ? 1 : -1
                        } else {
                            awayDirection = nextRandom(in: 0...1) < 0.5 ? -1 : 1
                        }
                        
                        let chainCol = clamp(
                            chainPrevious.column + awayDirection,
                            min: safeMinColumn,
                            max: safeMaxColumn
                        )
                        
                        let chainCell = makeCell(column: chainCol, row: chainRow)
                        
                        guard isCellFree(chainCell) else { break }
                        guard isReachable(from: chainPrevious, to: chainCell) else { break }
                        guard !wouldStack(column: chainCol, row: chainRow) else { break }
                        
                        decorations.append(chainCell)
                        placeCell(chainCell, into: &allCells)
                        chainPrevious = chainCell
                    }
                }
                break
            }
        }
        
        return decorations
    }
    
    // MARK: - Zone Helpers
    
    private func zone(for column: Int) -> Zone {
        let range = safeMaxColumn - safeMinColumn + 1
        let third = CGFloat(range) / 3.0
        let relative = CGFloat(column - safeMinColumn)
        
        if relative < third { return .left }
        if relative < third * 2.0 { return .center }
        return .right
    }
    
    // MARK: - Reachability
    
    private func isReachable(from previous: PlatformCell, to next: PlatformCell) -> Bool {
        let rowGap = next.row - previous.row
        
        let prevPos = worldPosition(for: previous)
        let nextPos = worldPosition(for: next)
        
        let dx = abs(nextPos.x - prevPos.x)
        
        if rowGap == 0 {
            return dx <= gridCellWidth * 2.0
        }
        
        if rowGap == 1 {
            return dx <= gridCellWidth * 1.5
        }
        
        return false
    }
    
    // MARK: - Cell Helpers
    
    private func makeCell(column: Int, row: Int, offsetRange: CGFloat = 30) -> PlatformCell {
        let clampedCol = clamp(
            column,
            min: safeMinColumn,
            max: safeMaxColumn
        )
        
        var offX = nextRandom(in: -offsetRange...offsetRange)
        let offY = nextRandom(in: -8...8)
        
        let rawX = CGFloat(clampedCol) * gridCellWidth + gridCellWidth / 2 + offX
        let margin = config.platformSize.width / 2 + 20
        let minX = margin
        let maxX = config.mapWidth - margin
        if rawX < minX {
            offX += (minX - rawX)
        } else if rawX > maxX {
            offX -= (rawX - maxX)
        }
        
        return PlatformCell(
            column: clampedCol,
            row: row,
            offsetX: offX,
            offsetY: offY
        )
    }
    
    private func key(for cell: PlatformCell) -> CellKey {
        CellKey(column: cell.column, row: cell.row)
    }
    
    private func worldPosition(for cell: PlatformCell) -> CGPoint {
        let x = CGFloat(cell.column) * gridCellWidth + gridCellWidth / 2 + cell.offsetX
        let y = config.startY + CGFloat(cell.row) * gridRowHeight + cell.offsetY
        return CGPoint(x: x, y: y)
    }
    
    private func isCellFree(_ cell: PlatformCell) -> Bool {
        guard cell.column >= 0, cell.column < config.gridColumns else  { return false }
        guard cell.row >= 0, cell.row < config.gridRows else { return false }
        return !occupiedCells.contains(key(for: cell))
    }
    
    private func placeCell(_ cell: PlatformCell, into list: inout [PlatformCell]) {
        let k = key(for: cell)
        guard !occupiedCells.contains(k) else { return }
        occupiedCells.insert(k)
        platformsByRow[cell.row, default: []].append(cell)
        list.append(cell)
    }
    
    private func platformCountOnRow(_ row: Int) -> Int {
        platformsByRow[row]?.count ?? 0
    }
    
    private func createPlatform(from cell: PlatformCell, type: PlatformType) -> GeneratedPlatform {
        GeneratedPlatform(
            position: worldPosition(for: cell),
            textureName: "PlatformEarth",
            type: type
        )
    }
    
    // MARK: - Trap Generation
    private func generateTraps(allCells: [PlatformCell]) -> [GeneratedTrap] {
        var traps: [GeneratedTrap] = []
        let maxRow = config.gridRows - 5
        
        var trappedPlatformIndices = Set<Int>()
        var placedTrapPositions: [CGPoint] = []
        let minTrapDistance: CGFloat = 250
        
        let trapRequests = buildTrapRequests()
        
        for trapRequest in trapRequests {
            var placed = false
            
            switch trapRequest.placement {
            case .platform:
                var candidates = Array(2..<allCells.count).filter{ !trappedPlatformIndices.contains($0) && allCells[$0].row < config.gridRows - 3 }
                shuffleArray(&candidates)
                
                for i in candidates {
                    let cell = allCells[i]
                    let pos = worldPosition(for: cell)
                    let trapPosition = CGPoint(
                        x: pos.x,
                        y: pos.y + config.platformSize.height / 2 + 16
                    )
                    
                    guard isFarEnoughFromOtherTraps(
                        trapPosition,
                        placedPositions: placedTrapPositions,
                        minDistance: minTrapDistance
                    ) else {
                        continue
                    }
                    
                    traps.append(GeneratedTrap(position: trapPosition, type: trapRequest.type))
                    trappedPlatformIndices.insert(i)
                    placedTrapPositions.append(trapPosition)
                    placed = true
                    
                    break
                }
                
            case .air:
                var candidates = Array(3...maxRow)
                shuffleArray(&candidates)
                
                for row in candidates {
                    for _ in 0..<5 {
                        guard let trapPosition = airTrapPositionNearPlatform(row: row) else { continue }
                        
                        if isFarEnoughFromOtherTraps(
                            trapPosition,
                            placedPositions: placedTrapPositions,
                            minDistance: minTrapDistance
                        ) {
                            traps.append(GeneratedTrap(position: trapPosition, type: trapRequest.type))
                            placedTrapPositions.append(trapPosition)
                            placed = true
                            break
                        }
                    }
                    if placed { break }
                }
            }
        }
        
        return traps
    }
    
    private func buildTrapRequests() -> [(type: TrapType, placement: TrapPlacement)] {
        var requests: [(type: TrapType, placement: TrapPlacement)] = []
        
        for _ in 0..<config.blackHoleCount {
            requests.append((.blackHole, .air))
        }
        
        for _ in 0..<config.forceFieldCount {
            requests.append((.forceField, .air))
        }
        
        for _ in 0..<config.purpleSlimeCount {
            requests.append((.purpleSlime, .platform))
        }
        
        for _ in 0..<config.electricCoilCount {
            requests.append((.electricCoil, .platform))
        }
        
        for _ in 0..<config.cometDustCount {
            requests.append((.cometDust, .platform))
        }
        
        shuffleArray(&requests)
        return requests
    }
    
    private func shuffleArray<T>(_ array: inout [T]) {
        for i in stride(from: array.count - 1, through: 1, by: -1) {
            let j = randomSource.nextInt(upperBound: i + 1)
            array.swapAt(i, j)
        }
    }
    
    private func airTrapPositionNearPlatform(row: Int) -> CGPoint? {
        let nearbyRows = [row, row - 1, row + 1]
        var nearbyCells: [PlatformCell] = []
        
        for nearbyRow in nearbyRows {
            if let cells = platformsByRow[nearbyRow] {
                nearbyCells.append(contentsOf: cells)
            }
        }
        
        guard !nearbyCells.isEmpty else {
            return nil
        }
        
        for _ in 0..<20 {
            guard let baseCell = randomElement(from: nearbyCells) else {
                return nil
            }
            
            let basePos = worldPosition(for: baseCell)
            var sides = [-1, 1]
            shuffleArray(&sides)
            
            for side in sides {
                let offsetX = CGFloat(nextRandomInt(90...150)) * CGFloat(side)
                let offsetY = CGFloat(nextRandomInt(40...90))
                
                let margin = config.platformSize.width / 2 + 40
                
                let position = CGPoint(
                    x: clamp(basePos.x + offsetX, min: margin, max: config.mapWidth - margin),
                    y: basePos.y + offsetY
                )
                
                if !isInJumpPath(position, row: row)  && !isTooCloseToAnyPlatform(position, row: row){
                    return position
                }
            }
        }
        return nil
    }
    
    private func isFarEnoughFromOtherTraps(
        _ position: CGPoint,
        placedPositions: [CGPoint],
        minDistance: CGFloat
    ) -> Bool {
        for placed in placedPositions {
            let dx = position.x - placed.x
            let dy = position.y - placed.y
            let distance = sqrt(dx * dx + dy * dy)
            
            if distance < minDistance {
                return false
            }
        }
        
        return true
    }
    
    private func isInJumpPath(_ position: CGPoint, row: Int) -> Bool {
        let trapX = position.x
        let margin: CGFloat = 100

        let checkRows = [row - 2, row - 1, row, row + 1, row + 2]

        var belowCells: [PlatformCell] = []
        var aboveCells: [PlatformCell] = []

        for r in checkRows {
            guard let cells = platformsByRow[r] else { continue }
            for cell in cells {
                let cellY = worldPosition(for: cell).y
                if cellY < position.y {
                    belowCells.append(cell)
                } else {
                    aboveCells.append(cell)
                }
            }
        }

        // Check if trap is between any below-above platform pair
        for below in belowCells {
            let belowX = worldPosition(for: below).x

            for above in aboveCells {
                let aboveX = worldPosition(for: above).x

                let minX = min(belowX, aboveX) - margin
                let maxX = max(belowX, aboveX) + margin

                if trapX >= minX && trapX <= maxX {
                    return true
                }
            }
        }

        // Check if trap is directly above or below any platform
        for r in checkRows {
            guard let cells = platformsByRow[r] else { continue }
            for cell in cells {
                let cellX = worldPosition(for: cell).x
                if abs(trapX - cellX) < margin {
                    return true
                }
            }
        }

        return false
    }
    
    private func isTooCloseToAnyPlatform(_ position: CGPoint, row: Int) -> Bool {
        let minDistance: CGFloat = 150 // from center of platform
        let checkRows = [row - 1, row, row + 1]

        for checkRow in checkRows {
            guard let cells = platformsByRow[checkRow] else { continue }

            for cell in cells {
                let platPos = worldPosition(for: cell)
                let dx = abs(position.x - platPos.x)
                let dy = abs(position.y - platPos.y)
                let distance = sqrt(dx * dx + dy * dy)

                if distance < minDistance {
                    return true
                }
            }
        }

        return false
    }

    // MARK: - Random Helpers
    
    private func nextRandom(in range: ClosedRange<CGFloat>) -> CGFloat {
        let f = randomSource.nextUniform()
        return range.lowerBound + CGFloat(f) * (range.upperBound - range.lowerBound)
    }
    
    private func nextRandomInt(_ range: ClosedRange<Int>) -> Int {
        let lower = range.lowerBound
        let upper = range.upperBound
        guard upper >= lower else { return lower }
        
        let count = upper - lower + 1
        return lower + randomSource.nextInt(upperBound: count)
    }
    
    private func randomElement<T>(from array: [T]) -> T? {
        guard !array.isEmpty else { return nil }
        let index = randomSource.nextInt(upperBound: array.count)
        return array[index]
    }
    
    private func lerp(_ a: CGFloat, _ b: CGFloat, _ t: CGFloat) -> CGFloat {
        a + (b - a) * min(max(t, 0), 1)
    }
    
    private func clamp(_ value: Int, min minValue: Int, max maxValue: Int) -> Int {
        Swift.min(Swift.max(value, minValue), maxValue)
    }
    
    private func clamp(_ value: CGFloat, min minValue: CGFloat, max maxValue: CGFloat) -> CGFloat {
        Swift.min(Swift.max(value, minValue), maxValue)
    }
}
